#include "PrimitiveRenderer.hpp"

#include "AppHandler.hpp"
#include "Asset/Shader.hpp"
#include "Asset/Surface.hpp"
#include "Generated/GmlFunc.hpp"
#include "GraphicsApiHandler.hpp"

namespace CppProject
{
	Shader* PrimitiveRenderer::prShader = nullptr;

	PrimitiveRenderer::PrimitiveRenderer()
	{
		halign = fa_left;
		valign = fa_top;

		if (!prShader)
			prShader = new Shader("primitive", Shader::PRIMITIVE);
	}

	void PrimitiveRenderer::Begin(IntType mode, IntType texture, QTransform transform)
	{
		// Get OpenGL drawing mode
		Shader::RenderMode renderMode;
		switch (mode)
		{
			case pr_pointlist: renderMode = Shader::POINT_LIST; break;
			case pr_linelist:
			case pr_linestrip: renderMode = Shader::LINE_LIST; break;
			case pr_trianglelist:
			case pr_trianglestrip:
			case pr_trianglefan: renderMode = Shader::TRIANGLE_LIST; break;
		}

		// Mode changed, submit last batch
		if (this->renderMode != Shader::NO_MODE && renderMode != this->renderMode)
			SubmitBatch();

		// Submit texture
		if (GFX->shader->useBaseTexture)
			uvRect = GFX->shader->SubmitTexture("_uBaseTexture", texture, true);
		else // UV transform is done in shader
			uvRect = { 0.0, 0.0, 1.0, 1.0 };

		this->mode = mode;
		this->renderMode = renderMode;
		this->transform = transform;
		beginIndex = vertices.Size();
		currentIndex = 0;
		depth += 0.0001;
	}

	void PrimitiveRenderer::Add(PrimitiveVertex vertex)
	{
		IntType nextVertexIndex = vertices.Size();

		// Convert from strip/fan to list
		switch (mode)
		{
			case pr_linestrip:
			{
				if (currentIndex > 1)
				{
					indices.Append(nextVertexIndex - 1);
					currentIndex++;
				}
				break;
			}

			case pr_trianglestrip:
			{
				if (currentIndex > 2)
				{
					indices.Append(nextVertexIndex - 1);
					indices.Append(nextVertexIndex - 2);
					currentIndex += 2;
				}
				break;
			}

			case pr_trianglefan:
			{
				if (currentIndex > 2)
				{
					indices.Append(beginIndex);
					indices.Append(nextVertexIndex - 1);
					currentIndex += 2;
				}
				break;
			}
		}

		// Add vertex
		vertex.Apply(transform, depth, uvRect);
		vertices.Append(vertex);

		// Add index
		indices.Append(nextVertexIndex);
		currentIndex++;
	}

	void PrimitiveRenderer::SubmitBatch()
	{
		if (!vertices.Size() || !GFX->shader || !GFX->shader->IsLoaded())
			return;

		IntType vertSize = vertices.Size() * sizeof(PrimitiveVertex);
		IntType indSize = indices.Size() * sizeof(uint32_t);

	#if API_D3D11
		// Create/update vertex buffer
		if (vertSize > vertexBufferSize)
		{
			releaseAndReset(d3dVertexBuffer);

			D3D11_BUFFER_DESC vBufferDesc = {};
			vBufferDesc.BindFlags = D3D11_BIND_VERTEX_BUFFER;
			vBufferDesc.CPUAccessFlags = D3D11_CPU_ACCESS_WRITE;
			vBufferDesc.ByteWidth = vertSize;
			vBufferDesc.Usage = D3D11_USAGE_DYNAMIC;

			D3D11_SUBRESOURCE_DATA vBufferData = { vertices.Data(), 0, 0 };
			D3DCheckError(D3DDevice->CreateBuffer(&vBufferDesc, &vBufferData, &d3dVertexBuffer));

			vertexBufferSize = vertSize;
		}
		else
		{
			D3D11_MAPPED_SUBRESOURCE vBufferRes;
			D3DCheckError(D3DContext->Map(d3dVertexBuffer, 0, D3D11_MAP_WRITE_DISCARD, 0, &vBufferRes));
			memcpy(vBufferRes.pData, vertices.Data(), vertSize);
			D3DContext->Unmap(d3dVertexBuffer, 0);
		}

		// Create/update index buffer
		if (indSize > indexBufferSize)
		{
			releaseAndReset(d3dIndexBuffer);

			D3D11_BUFFER_DESC iBufferDesc = {};
			iBufferDesc.BindFlags = D3D11_BIND_INDEX_BUFFER;
			iBufferDesc.CPUAccessFlags = D3D11_CPU_ACCESS_WRITE;
			iBufferDesc.ByteWidth = indSize;
			iBufferDesc.Usage = D3D11_USAGE_DYNAMIC;

			D3D11_SUBRESOURCE_DATA iBufferData = { indices.Data(), 0, 0 };
			D3DCheckError(D3DDevice->CreateBuffer(&iBufferDesc, &iBufferData, &d3dIndexBuffer));

			indexBufferSize = indSize;
		}
		else
		{
			D3D11_MAPPED_SUBRESOURCE iBufferRes;
			D3DCheckError(D3DContext->Map(d3dIndexBuffer, 0, D3D11_MAP_WRITE_DISCARD, 0, &iBufferRes));
			memcpy(iBufferRes.pData, indices.Data(), indSize);
			D3DContext->Unmap(d3dIndexBuffer, 0);
		}

		// Bind buffers
		UINT stride = sizeof(PrimitiveVertex);
		UINT offset = 0;
		D3DContext->IASetVertexBuffers(0, 1, &d3dVertexBuffer, &stride, &offset);
		D3DContext->IASetIndexBuffer(d3dIndexBuffer, DXGI_FORMAT_R32_UINT, 0);
	#else
		// Create buffers
		if (!glVertexBuffer)
		{
			glVertexBuffer = new QOpenGLBuffer(QOpenGLBuffer::VertexBuffer);
			glVertexBuffer->create();
			glVertexBuffer->setUsagePattern(QOpenGLBuffer::DynamicDraw);

			glIndexBuffer = new QOpenGLBuffer(QOpenGLBuffer::IndexBuffer);
			glIndexBuffer->create();
			glIndexBuffer->setUsagePattern(QOpenGLBuffer::DynamicDraw);
		}

		// Bind buffers
		if (!glVertexBuffer->bind() || !glIndexBuffer->bind())
			return;

		// Write data
		if (vertSize > vertexBufferSize)
		{
			glVertexBuffer->allocate(vertices.Data(), vertSize);
			vertexBufferSize = vertSize;
		}
		else
			glVertexBuffer->write(0, vertices.Data(), vertSize);

		if (indSize > indexBufferSize)
		{
			glIndexBuffer->allocate(indices.Data(), indSize);
			indexBufferSize = indSize;
		}
		else
			glIndexBuffer->write(0, indices.Data(), indSize);
	#endif
		vertices.Reset();

		// Set shader
		GFX->shader->SubmitMatrix(Shader::MVP, GFX->surface->ortho, true);

		// Submit (disable mipmap and culling)
		BoolType culling = GFX->culling;
		GFX->SetCulling(false);
		GFX->shader->SubmitVertices(renderMode, indices.Size());
		GFX->SetCulling(culling);

	#if API_OPENGL
		glVertexBuffer->release();
		glIndexBuffer->release();
	#endif

		renderCalls++;
		if (renderMode == Shader::LINE_LIST)
			linesSubmitted += indices.Size() / 2;
		else if (renderMode == Shader::TRIANGLE_LIST)
			trianglesSubmitted += indices.Size() / 3;

		indices.Reset();
		mode = 0;
		renderMode = Shader::NO_MODE;
		depth = 0.0;
	}
}