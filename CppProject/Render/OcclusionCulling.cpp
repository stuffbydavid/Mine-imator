#include "OcclusionCulling.hpp"

#include "AppHandler.hpp"
#include "Asset/Shader.hpp"
#include "Asset/Surface.hpp"
#include "Generated/GmlFunc.hpp"
#include "FrameBuffer.hpp"

#include <cmath>
#include <limits>

namespace CppProject
{
	OcclusionCulling::~OcclusionCulling()
	{
		for (Query& query : queries)
			FreeQuery(query);
	}

	void OcclusionCulling::FreeQuery(Query& query)
	{
	#if OS_WINDOWS
		if (query.predicate)
			releaseAndReset(query.predicate);
	#endif
		if (query.id)
			GFX->glDeleteQueries(1, &query.id);
	}

	BoolType OcclusionCulling::Begin(const Bounds& bounds, IntType numIndices, BoolType safe)
	{
		// Small draws cost less than an extra query and proxy draw
		if (!GFX->occlusionCulling || !GFX->occlusionPass || !safe || bounds.empty || nextQuery >= 4096 ||
			numIndices < 1024 || !GFX->depthTest || GFX->depthFunc != cmpfunc_lessequal ||
			GFX->pointMultiview || !GFX->surface || !GFX->surface->frameBuffer->depthBuffer)
			return false;

		Shader* sceneShader = GFX->shader;
		Matrix clip = GFX->matrixVP * sceneShader->occlusionAAMatrix;
		RealType left = std::numeric_limits<RealType>::max(), bottom = left;
		RealType right = -left, top = right, depth = left;

		for (IntType corner = 0; corner < 8; corner++)
		{
			VecType point = clip * VecType(
				corner & 1 ? bounds.maxPoint.x : bounds.minPoint.x,
				corner & 2 ? bounds.maxPoint.y : bounds.minPoint.y,
				corner & 4 ? bounds.maxPoint.z : bounds.minPoint.z, 1.0);

			// A clipped box cannot safely be represented by its projected corners
			if (!std::isfinite(point.x) || !std::isfinite(point.y) ||
				!std::isfinite(point.z) || !std::isfinite(point.w) ||
				point.w <= 0.00001 || point.z <= 0.0)
				return false;

			left = std::min(left, point.x / point.w);
			right = std::max(right, point.x / point.w);
			bottom = std::min(bottom, point.y / point.w);
			top = std::max(top, point.y / point.w);
			depth = std::min(depth, point.z / point.w);
		}

		IntType width = 0, height = 0;
	#if OS_WINDOWS
		if (IS_D3D11)
		{
			UINT count = 1;
			D3D11_VIEWPORT viewport;
			D3DContext->RSGetViewports(&count, &viewport);
			if (!count || viewport.MinDepth != 0.0f || viewport.MaxDepth != 1.0f)
				return false;
			width = viewport.Width;
			height = viewport.Height;
		}
	#endif
		if (IS_OPENGL)
		{
			GLint viewport[4];
			GFX->glGetIntegerv(GL_VIEWPORT, viewport);
			width = viewport[2];
			height = viewport[3];
		}
		if (width <= 0 || height <= 0)
			return false;

		// Expand by two pixels and bias toward the camera to avoid edge/rounding false negatives
		left = std::max(-1.0, left - 4.0 / width);
		right = std::min(1.0, right + 4.0 / width);
		bottom = std::max(-1.0, bottom - 4.0 / height);
		top = std::min(1.0, top + 4.0 / height);
		depth = std::max(0.0, depth - 0.00001);
		if (left >= right || bottom >= top || depth >= 1.0)
			return false;

		if (!shader)
		{
			shader = new Shader("occlusion", Shader::VERTEX_BUFFER);
			if (!shader->IsLoaded())
				FATAL("Could not load occlusion query shader");

			quad.numVertices = 4;
			quad.numIndices = 6;
			quad.vertexData.Alloc(4);
			quad.indexData.Alloc(6);
			for (IntType i = 0; i < 4; i++)
			{
				quad.vertexData[i] = Vertex();
				quad.vertexData[i].x = i & 1 ? 1.0f : 0.0f;
				quad.vertexData[i].y = i & 2 ? 1.0f : 0.0f;
				quad.vertexData[i].z = 0.0f;
			}
			const uint32_t indices[] = { 0, 1, 2, 2, 1, 3 };
			memcpy(&quad.indexData[0], indices, sizeof(indices));
			quad.CreateBuffers();
		}

		if (nextQuery == queries.size())
		{
			Query query;
		#if OS_WINDOWS
			if (IS_D3D11)
			{
				D3D11_QUERY_DESC desc = { D3D11_QUERY_OCCLUSION_PREDICATE, 0 };
				D3DCheckError(D3DDevice->CreatePredicate(&desc, &query.predicate));
			}
		#endif
			if (IS_OPENGL)
			{
				GFX->glGenQueries(1, &query.id);
				GL_CHECK_ERROR();
			}
			queries.append(query);
		}
		Query& query = queries[nextQuery++];

	#if OS_WINDOWS
		ID3D11BlendState* blendState = nullptr;
		ID3D11DepthStencilState* depthState = nullptr;
		ID3D11RasterizerState* rasterState = nullptr;
		FLOAT blendFactor[4];
		UINT sampleMask = 0, stencilRef = 0;
		if (IS_D3D11)
		{
			D3DContext->OMGetBlendState(&blendState, blendFactor, &sampleMask);
			D3DContext->OMGetDepthStencilState(&depthState, &stencilRef);
			D3DContext->RSGetState(&rasterState);
			D3DContext->OMSetBlendState(GFX->d3dNoColorState, nullptr, sampleMask);
			D3DContext->OMSetDepthStencilState(GFX->d3dDepthStencilStateMap[GraphicsApiHandler::DEPTH_TEST_NO_WRITE], 0);
			D3DContext->RSSetState(GFX->d3dRasterizerStateMap[D3D11_CULL_NONE]);
		}
	#endif
		GLboolean colorMasks[8][4], depthMask = GL_FALSE, culling = GL_FALSE;
		GLint depthFunc = GL_LEQUAL;
		if (IS_OPENGL)
		{
			for (GLuint i = 0; i < 8; i++)
				GFX->glGetBooleani_v(GL_COLOR_WRITEMASK, i, colorMasks[i]);
			GFX->glGetBooleanv(GL_DEPTH_WRITEMASK, &depthMask);
			GFX->glGetIntegerv(GL_DEPTH_FUNC, &depthFunc);
			culling = GFX->glIsEnabled(GL_CULL_FACE);
			GFX->glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE);
			GFX->glDepthMask(GL_FALSE);
			GFX->glDepthFunc(GL_LEQUAL);
			GFX->glDisable(GL_CULL_FACE);
		}

		GFX->shader = shader;
		if (!shader->BeginUse())
			FATAL("Could not bind occlusion query shader");
		shader->SubmitVec4(shader->GetUniformIndex("uOcclusionRect"), left, bottom, right, top);
		shader->SubmitFloat(shader->GetUniformIndex("uOcclusionDepth"), depth);
		quad.BeginUse();
	#if OS_WINDOWS
		if (IS_D3D11)
			D3DContext->Begin(query.predicate);
	#endif
		if (IS_OPENGL)
			GFX->glBeginQuery(GL_SAMPLES_PASSED, query.id);

		shader->SubmitVertices(Shader::TRIANGLE_LIST, 6);

	#if OS_WINDOWS
		if (IS_D3D11)
			D3DContext->End(query.predicate);
	#endif
		if (IS_OPENGL)
			GFX->glEndQuery(GL_SAMPLES_PASSED);
		quad.EndUse();
		GFX->shader = sceneShader;

	#if OS_WINDOWS
		if (IS_D3D11)
		{
			D3DContext->VSSetShader(sceneShader->d3dVertexShader, nullptr, 0);
			D3DContext->PSSetShader(sceneShader->d3dPixelShader, nullptr, 0);
			D3DContext->GSSetShader(nullptr, nullptr, 0);
			D3DContext->OMSetBlendState(blendState, blendFactor, sampleMask);
			D3DContext->OMSetDepthStencilState(depthState, stencilRef);
			D3DContext->RSSetState(rasterState);
			releaseAndReset(blendState);
			releaseAndReset(depthState);
			releaseAndReset(rasterState);
			D3DContext->SetPredication(query.predicate, FALSE);
		}
	#endif
		if (IS_OPENGL)
		{
			if (!sceneShader->program->bind())
				FATAL("Could not restore scene shader after occlusion query");
			for (GLuint i = 0; i < 8; i++)
				GFX->glColorMaski(i, colorMasks[i][0], colorMasks[i][1], colorMasks[i][2], colorMasks[i][3]);
			GFX->glDepthMask(depthMask);
			GFX->glDepthFunc(depthFunc);
			if (culling)
				GFX->glEnable(GL_CULL_FACE);
			GFX->glBeginConditionalRender(query.id, GL_QUERY_NO_WAIT);
			GL_CHECK_ERROR();
		}

		active = true;
		return true;
	}

	void OcclusionCulling::End()
	{
		if (!active)
			return;
	#if OS_WINDOWS
		if (IS_D3D11)
			D3DContext->SetPredication(nullptr, FALSE);
	#endif
		if (IS_OPENGL)
		{
			GFX->glEndConditionalRender();
			GL_CHECK_ERROR();
		}
		active = false;
	}

	void OcclusionCulling::EndFrame()
	{
		while (queries.size() > nextQuery)
		{
			FreeQuery(queries.last());
			queries.removeLast();
		}
		nextQuery = 0;
	}
}
