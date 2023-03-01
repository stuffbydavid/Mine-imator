#include "Shader.hpp"

#include "AppHandler.hpp"
#include "AppWindow.hpp"
#include "Render/GLWidget.hpp"
#include "Render/GraphicsApiHandler.hpp"
#include "Render/Texture.hpp"
#include "Render/TexturePage.hpp"
#include "Render/VertexBufferRenderer.hpp"
#include "Type/ArrType.hpp"
#include "World/World.hpp"

#include <QProcess>

#if API_OPENGL
#undef __glext_h_
#include <qopenglext.h>

#define ENABLE_OPENGL_43 1
#endif

namespace CppProject
{
	QVector<Shader*> Shader::allShaders;
	TexturePage* Shader::currentPage = nullptr;
	QMap<QString, Shader::DataType> Shader::dataTypeNameMap = {
		{ "int", Shader::INT },
		{ "float", Shader::FLOAT },
		{ "vec2", Shader::VEC2 },
		{ "vec3", Shader::VEC3 },
		{ "vec4", Shader::VEC4 },
		{ "mat4", Shader::MAT4 },
		{ "sampler2D", Shader::SAMPLER2D }
	};
	QMap<Shader::DataType, IntType> Shader::dataTypeSizeMap = {
		{ Shader::INT, (IntType)sizeof(int32_t) },
		{ Shader::FLOAT, (IntType)sizeof(float) },
		{ Shader::VEC2, (IntType)sizeof(float) * 2 },
		{ Shader::VEC3, (IntType)sizeof(float) * 3 },
		{ Shader::VEC4, (IntType)sizeof(float) * 4 },
		{ Shader::MAT4, (IntType)sizeof(float) * 16 },
		{ Shader::SAMPLER2D, 0 }, // Not in buffer
	};
	QStringList Shader::matrixUniformName = {
		"_uMatrixMVP",
		"_uMatrixVP",
		"_uMatrixMV",
		"_uMatrixM",
		"_uMatrixV",
		"_uMatrixP"
	};
	QStringList Shader::gmMatrixUniformName = {
		"gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION]",
		"gm_Matrices[MATRIX_VIEW_PROJECTION]",
		"gm_Matrices[MATRIX_WORLD_VIEW]",
		"gm_Matrices[MATRIX_WORLD]",
		"gm_Matrices[MATRIX_VIEW]",
		"gm_Matrices[MATRIX_PROJECTION]"
	};

#if API_OPENGL
	QString Shader::glslVersion = "150 core"; // 3.2
	BoolType Shader::gl40Supported = false;
	BoolType Shader::gl43Supported = false;
	QOpenGLFunctions_4_3_Core* Shader::gl43Core = nullptr;
#endif

	Shader::Shader(QString name, IntType subAssetId) : Asset(ID_Shader, subAssetId, name)
	{
		allShaders.append(this);
		this->name = name;
		Load();
	}

	Shader::Shader(QString name, VertexFormat format, BoolType useBatching) : Asset(ID_Shader)
	{
		allShaders.append(this);
		this->name = name;
		this->vertexFormat = format;
		this->useBatching = useBatching;
		Load();
	}

	void Shader::Init()
	{
	#if API_OPENGL
		// Try compiling with a GLSL 4.0 feature (textureQueryLod) and GLSL 4.3 feature (SSBOs) to determine support
		QString gl43shader = "#version 430\nlayout(std430, binding = 2) buffer _ssbo { struct { int a; } _obj[1024]; };\nvoid main() {}";
		QString gl40shader = "#version 400\nuniform sampler2D _sampler;\nout vec2 _lod;\nvoid main() { _lod = textureQueryLod(_sampler, vec2(0.0, 0.0)); }";

		QOpenGLShader sh(QOpenGLShader::Vertex);
		if (sh.compileSourceCode(gl40shader))
		{
			gl40Supported = true;
			glslVersion = "400";

			if (ENABLE_OPENGL_43 && sh.compileSourceCode(gl43shader))
			{
				gl43Supported = true;
				gl43Core = new QOpenGLFunctions_4_3_Core;
				if (!gl43Core->initializeOpenGLFunctions())
					FATAL("Could not initialize OpenGL 4.3");
				glslVersion = "430";
			}
		}

		// Clear errors on Mac/Linux
	#if !OS_WINDOWS
		QProcess::execute("clear");
	#endif
		DEBUG("GLSL version " + glslVersion);
	#endif
	}

	void Shader::Load(BoolType useCache)
	{
		vsName = "/Shaders/" + name + ".vsh";
		fsName = "/Shaders/" + name + ".fsh";

	#if DEBUG_MODE // Load from Assets folder and re-load upon change
		vsName = ASSETS_DIR + vsName;
		fsName = ASSETS_DIR + fsName;
	#else // Load from memory
		vsName = ":" + vsName;
		fsName = ":" + fsName;
	#endif

		// Reset shader
		deleteAndReset(batchBufferData);
		batchBufferSize = 0;
		deleteAndReset(staticBufferData);
		staticBufferSize = 0;
		uniformNameMap.clear();
		uniformLocationMap.clear();
		uniforms.clear();
		numUniforms = 0;
		batchBufferObjectSize = 0;
		samplerNameMap.clear();
		numSamplers = 0;
		useBaseTexture = false;
		objRectUniformIndex = -1;
		for (IntType m = 0; m < 6; m++)
			matrixState[m] = MatrixState();
		numOutputs = 0;

		// Vertex shader
		QFile vsFile(vsName);
		if (!vsFile.open(QFile::ReadOnly | QFile::Text))
		{
			WARNING("Shader: " + vsName + " not found");
			return;
		}

		// Fragment shader
		QFile fsFile(fsName);
		if (!fsFile.open(QFile::ReadOnly | QFile::Text))
		{
			WARNING("Shader: " + fsName + " not found");
			return;
		}

		// Read code
		QString vsCode = QTextStream(&vsFile).readAll();
		QString fsCode = QTextStream(&fsFile).readAll();

		// Find vertex format
		if (vertexFormat == UNKNOWN)
		{
			if (vsCode.contains("in_Normal"))
			{
				useBatching = true;
				vertexFormat = VERTEX_BUFFER;
			}
			else
				vertexFormat = PRIMITIVE;
		}

		// Parse GLES code to HLSL/GLSL depending on API used
		LoadCode(vsCode, fsCode, useCache);

		// Store texture uniforms
		if (numSamplers > 0)
		{
			uvRectUniform = uniforms[uniformNameMap["_uUvRect"]];
			texRepeatUniform = uniforms[uniformNameMap["_uTexRepeat"]];
		}
	}

	BoolType Shader::IsLoaded() const
	{
	#if API_D3D11
		return d3dVertexShader && d3dPixelShader;
	#else
		return program;
	#endif
	}

	bool Shader::BeginUse()
	{
		if (!IsLoaded())
			return false;

	#if API_D3D11
		D3DContext->VSSetShader(d3dVertexShader, 0, 0);
		D3DContext->PSSetShader(d3dPixelShader, 0, 0);
	#else
		if (!program->bind())
			return false;
	#endif

		// Reset samplers
		for (IntType s = 0; s < numSamplers; s++)
		{
			samplerState[s].changed = false;
			samplerState[s].currentTexId = -1;
			samplerState[s].filter = GFX->texFilter;
			samplerState[s].mipMap = GFX->mipMap;
			samplerUvRect[s] = { 0.f, 0.f, 1.f, 1.f };
			samplerRepeat[s] = GFX->texRepeat;
		}

		// Reset matrices
		for (IntType m = 0; m < 6; m++)
			if (matrixState[m].active)
				matrixState[m].changed = false;

		if (useBatching)
		{
			// Clear batch buffer
			memset(batchBufferData, 0, batchBufferSize);
			batchBufferObjectIndex = 0;

		#if API_OPENGL
			// Bind SSBO
			gl43Core->glShaderStorageBlockBinding(program->programId(), glSsboBlockIndex, 2);
			GL_CHECK_ERROR();
		#endif
		}

	#if API_D3D11
		// Clear static buffer
		memset(staticBufferData, 0, staticBufferSize);
	#else
		GFX->glBindVertexArray(GFX->glCurrentVboId);
		GL_CHECK_ERROR();
	#endif

		return true;
	}

	bool Shader::EndUse()
	{
		if (!IsLoaded())
			return false;

	#if API_D3D11
	#else
		program->release();
		GFX->glBindVertexArray(0);
		GL_CHECK_ERROR();
	#endif
		return true;
	}

	void Shader::SubmitInt(IntType index, int32_t in)
	{
		if (!IsLoaded() || index < 0 || index >= numUniforms)
			return;

		const UniformState& uni = uniforms[index];
		if (uni.type == FLOAT)
		{
			SubmitFloat(index, in);
			return;
		}
		if (uni.type != INT)
			WARNING("Shader: Submitting int into " + uni.typeName + " uniform " + uni.name);

	#if API_OPENGL
		if (uni.isStatic)
			program->setUniformValue(uni.glLocation, in);
		else
	#endif
		WriteUniformValue(uni, &in);
	}

	void Shader::SubmitFloat(IntType index, float fl)
	{
		if (!IsLoaded() || index < 0 || index >= numUniforms)
			return;

		const UniformState& uni = uniforms[index];
		if (uni.type == INT)
		{
			SubmitInt(index, fl);
			return;
		}
		if (uni.type != FLOAT)
			WARNING("Shader: Submitting float into " + uni.typeName + " uniform " + uni.name);

	#if API_OPENGL
		if (uni.isStatic)
			program->setUniformValue(uni.glLocation, fl);
		else
	#endif
		WriteUniformValue(uni, &fl);
	}

	void Shader::SubmitFloatArray(IntType index, VarType& arrOrMatrix)
	{
		if (!IsLoaded() || index < 0 || index >= numUniforms)
			return;

		// Matrix
		if (arrOrMatrix.IsMatrix())
		{
			SubmitMat4(index, arrOrMatrix.Mat());
			return;
		}
		else if (!arrOrMatrix.IsArray() && !arrOrMatrix.IsVec())
		{
			WARNING("Shader: Submitting non-array/vector/matrix into SubmitFloatArray");
			return;
		}

		const UniformState& uni = uniforms[index];
		IntType tupleSize = uni.bufferSize / sizeof(float);

		// Find number of floats
		ArrType arr = arrOrMatrix.ToArr();
		IntType floatsNum = arr.Size();
		if (arrOrMatrix.IsVec()) // Vector
			floatsNum = std::min(tupleSize, arr.Size());
		else if (uni.arrayMaxSize > 0)
			floatsNum = uni.arrayMaxSize * tupleSize;

		// Create float array from VarTypes to submit
		float* floats = new float[floatsNum];
		IntType i = 0, arrIndex = 0;
		while (i < floatsNum && arrIndex < arr.Size())
		{
			floats[i++] = arr.Value(arrIndex++).Real();

		#if API_D3D11
			// Pad so each element is 4 floats
			switch (uni.type)
			{
				case INT:
				case FLOAT: i += 3; break; // 1 float/ints written, skip 3
				case VEC2: if (i % 4 == 2) i += 2; break; // 2 floats written, skip 2
				case VEC3: if (i % 4 == 3) i++; break; // 3 floats written, skip 1
			}
		#endif
		}

	#if API_OPENGL
		if (uni.isStatic)
			program->setUniformValueArray(uni.glLocation, floats, floatsNum / tupleSize, tupleSize);
		else
	#endif
		WriteUniformValue(uni, floats, floatsNum * sizeof(float));
		delete[] floats;
	}

	void Shader::SubmitVec2(IntType index, float x, float y)
	{
		if (!IsLoaded() || index < 0 || index >= numUniforms)
			return;

		const UniformState& uni = uniforms[index];
		if (uni.type != VEC2)
			WARNING("Shader: Submitting vec2 into " + uni.typeName + " uniform " + uni.name);

		if (uni.name == "uTexScale") // set uTexScale to 1
			x = y = 1.0;

	#if API_OPENGL
		if (uni.isStatic)
			program->setUniformValue(uni.glLocation, x, y);
		else
	#endif
		{
			float dat[2] = { x, y };
			WriteUniformValue(uni, dat);
		}
	}

	void Shader::SubmitVec3(IntType index, float x, float y, float z)
	{
		if (!IsLoaded() || index < 0 || index >= numUniforms)
			return;

		const UniformState& uni = uniforms[index];
		if (uni.type != VEC3)
			WARNING("Shader: Submitting vec3 into " + uni.typeName + " uniform " + uni.name);

	#if API_OPENGL
		if (uni.isStatic)
			program->setUniformValue(uni.glLocation, x, y, z);
		else
	#endif
		{
			float dat[3] = { x, y, z };
			WriteUniformValue(uni, dat);
		}
	}

	void Shader::SubmitVec4(IntType index, float x, float y, float z, float w)
	{
		if (!IsLoaded() || index < 0 || index >= numUniforms)
			return;

		const UniformState& uni = uniforms[index];
		if (uni.type != VEC4)
			WARNING("Shader: Submitting vec4 into " + uni.typeName + " uniform " + uni.name);

	#if API_OPENGL
		if (uni.isStatic)
			program->setUniformValue(uni.glLocation, x, y, z, w);
		else
	#endif
		{
			float dat[4] = { x, y, z, w };
			WriteUniformValue(uni, dat);
		}
	}

	void Shader::SubmitMat4(IntType index, const Matrix& matrix)
	{
		if (!IsLoaded() || index < 0 || index >= numUniforms)
			return;

		const UniformState& uni = uniforms[index];
		if (uni.type != MAT4)
			WARNING("Shader: Submitting matrix into " + uni.typeName + " uniform " + uni.name);

		float floats[4][4];
		matrix.Copy(floats[0]);

	#if API_OPENGL
		if (uni.isStatic)
			program->setUniformValue(uni.glLocation, floats);
		else
	#endif
			WriteUniformValue(uni, floats);
	}

	void Shader::SubmitMat4Array(IntType index, ArrType arr)
	{
		if (!IsLoaded() || index < 0 || index >= numUniforms)
			return;

		const UniformState& uni = uniforms[index];
		if (uni.type != MAT4)
			WARNING("Shader: Submitting matrix into " + uni.typeName + " uniform " + uni.name);

	#if API_OPENGL
		if (uni.isStatic)
		{
			float floats[16];
			QVector<QMatrix4x4> mat(arr.Size());
			for (IntType m = 0; m < arr.Size(); m++)
			{
				arr.Value(m).Mat().matrix.Copy(floats);
				mat[m] = QMatrix4x4(floats).transposed();
			}
			program->setUniformValueArray(uni.glLocation, mat.data(), mat.size());
		}
		else
	#endif
		{
			float* floats = new float[arr.Size() * 16];
			for (IntType m = 0; m < arr.Size(); m++)
				arr.Value(m).Mat().matrix.Copy(&floats[m * 16]);
			WriteUniformValue(uni, floats);
		}
	}

	UvRect Shader::SubmitTexture(StringType samplerName, IntType id, bool getUvRect)
	{
		return SubmitTexture(samplerNameMap.value(samplerName, -1), id, getUvRect);
	}

	UvRect Shader::SubmitTexture(IntType sampler, IntType id, bool getUvRect)
	{
		if (!IsLoaded())
			return UvRect();

		if (sampler < 0 || sampler >= numSamplers || sampler >= 32)
		{
			WARNING("Shader: Sampler index out of range: " + NumStr(sampler));
			return UvRect();
		}

		UvRect uvRect;

		if (id <= 0) // Default blank pixel from texture page
		{
			id = currentPage->GetTexture()->GetId();
			uvRect = currentPage->defaultLocation->uvRect;
		}
		else if (TexturePageLocation* pageLoc = TexturePageLocation::Find(id)) // Texture page location
		{
			id = pageLoc->page->GetTexture()->GetId();
			uvRect = pageLoc->uvRect;
			currentPage = pageLoc->page;
		}
		else // OpenGL texture
			uvRect = { 0.0, 0.0, 1.0, 1.0 }; // Keep UVs

		// Bind new id to sampler
		SamplerState& state = samplerState[sampler];
		if (state.currentTexId != id)
		{
			if (state.currentTexId > -1)
				GFX->SubmitBatch();

			state.mipMap = GFX->mipMap;
			state.changed = true;
		}

		state.currentTexId = id;

		if (getUvRect) // UV transform is done on CPU
			this->samplerUvRect[sampler] = { 0.f, 0.f, 1.f, 1.f };
		else // UV transform is done in shader
		{
			this->samplerUvRect[sampler] = { (float)uvRect.x, (float)uvRect.y, (float)uvRect.w, (float)uvRect.h };
			if (useBatching && sampler == 0) // First sampler uses object UV Rect
				SubmitVec4(objRectUniformIndex, uvRect.x, uvRect.y, uvRect.w, uvRect.h);
		}

		return uvRect;
	}

	void Shader::SubmitMatrix(MatrixId matrix, const Matrix& value, BoolType clearMvpMatrices)
	{
		if (!IsLoaded())
			return;

		MatrixState& state = matrixState[matrix];
		if (matrix == M && useBatching) // Submit world matrix to SSBO
		{
			float m[16];
			value.Copy(m);
			WriteUniformValue(state.uniform, m);

			// Send in MVP (better precision to multiply on CPU)
			Matrix objMvp = value * GFX->matrixVP;
			objMvp.Copy(m);
			WriteUniformValue(matrixState[MVP].uniform, m);
		}

		state.current = value;
		state.changed = true;

		// Avoid MVP getting overwritten on submit
		if (clearMvpMatrices)
		{
			matrixState[M].changed = false;
			matrixState[V].changed = false;
			matrixState[P].changed = false;
		}
	}

	bool Shader::SubmitObject()
	{
		if (!IsLoaded()) // OpenGL program not loaded
			return false;

		if (!useBatching) // Buffers not enabled
			return true;

		if (batchBufferObjectIndex == batchBufferMaxObjects - 1) // Out of space
			return true;

		batchBufferObjectIndex++;

		// Copy uniform data to next object
		memcpy(batchBufferData + batchBufferObjectIndex * batchBufferObjectSize,
			   batchBufferData + (batchBufferObjectIndex - 1) * batchBufferObjectSize,
			   batchBufferObjectSize);

		return false;
	}

	void Shader::SubmitVertices(RenderMode mode, IntType numIndices)
	{
		if (!IsLoaded())
			return;

		// Model * View
		if (matrixState[MV].active && (matrixState[M].changed || matrixState[V].changed))
			SubmitMatrix(MV, matrixState[M].current * matrixState[V].current);

		// View * Projection
		if (matrixState[VP].active && (matrixState[V].changed || matrixState[P].changed))
			SubmitMatrix(VP, matrixState[V].current * matrixState[P].current);

		// Model * View * Projection
		if (matrixState[MVP].active && (matrixState[M].changed || matrixState[V].changed || matrixState[P].changed))
		{
			if (matrixState[MV].active) // Save one multiplication
				SubmitMatrix(MVP, matrixState[MV].current * matrixState[P].current);
			else
				SubmitMatrix(MVP, (matrixState[M].current * matrixState[V].current) * matrixState[P].current);
		}

		// Submit static matrices
		for (MatrixState& state : matrixState)
		{
			if (state.active && state.uniform.isStatic && state.changed)
			{
				float floats[4][4];
				state.current.Copy(floats[0]);
			#if API_D3D11
				WriteUniformValue(state.uniform, floats);
			#else
				program->setUniformValue(state.uniform.glLocation, floats);
			#endif
				state.changed = false;
			}
		}

		// Bind textures and submit samplers
	#if API_D3D11
		QVector<ID3D11SamplerState*> texSamplers(numSamplers);
		QVector<ID3D11ShaderResourceView*> texSRVs(numSamplers);
	#endif
		for (IntType s = 0; s < numSamplers; s++)
		{
			const SamplerState& state = samplerState[s];
			if (state.currentTexId > -1)
			{
			#if API_D3D11
				BoolType magFilter = state.filter;
				BoolType mipFilter = false;
				if (Texture::hasMipMaps.value(state.currentTexId, false) && state.mipMap)
					mipFilter = true;

				D3D11_FILTER filter;
				if (mipFilter && magFilter)
					filter = D3D11_FILTER_MIN_POINT_MAG_MIP_LINEAR;
				else if (!mipFilter && magFilter)
					filter = D3D11_FILTER_MIN_POINT_MAG_LINEAR_MIP_POINT;
				else if (mipFilter && !magFilter)
					filter = D3D11_FILTER_MIN_MAG_POINT_MIP_LINEAR;
				else
					filter = D3D11_FILTER_MIN_MAG_MIP_POINT;

				texSamplers[s] = GFX->d3dSamplerStateMap.value(filter);
				texSRVs[s] = Texture::d3dIdSRVMap.value(state.currentTexId);
			#else
				GLenum magFilter = state.filter ? GL_LINEAR : GL_NEAREST;
				GLenum minFilter = magFilter;
				if (Texture::hasMipMaps.value(state.currentTexId, false) && state.mipMap)
					minFilter = GL_NEAREST_MIPMAP_LINEAR;

				GFX->glActiveTexture(GL_TEXTURE0 + s);
				GFX->glBindTexture(GL_TEXTURE_2D, state.currentTexId);
				GFX->glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
				GFX->glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
				GFX->glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, minFilter);
				GFX->glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, magFilter);
				GFX->glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_LOD_BIAS, GFX->lodBias);
				GL_CHECK_ERROR();

				program->setUniformValue(state.glLocation, (GLint)s);
			#endif
				samplerState[s].changed = false;
			}
		}

	#if API_D3D11
		D3DContext->PSSetSamplers(0, numSamplers, texSamplers.data());
		D3DContext->PSSetShaderResources(0, numSamplers, texSRVs.data());

		// Submit UvRects/repeat options
		if (numSamplers > 0)
		{
			WriteUniformValue(uvRectUniform, samplerUvRect, numSamplers * sizeof(UvRect));

			for (IntType i = 0; i < numSamplers; i++)
				samplerRepeatData[i * 4] = samplerRepeat[i];
			WriteUniformValue(texRepeatUniform, samplerRepeatData, samplerRepeatDataSize * sizeof(int32_t));
		}

		// Update and submit constant buffers
		QVector<ID3D11Buffer*> cBuffers;
		if (d3dStaticBuffer)
		{
			D3DContext->UpdateSubresource(d3dStaticBuffer, 0, nullptr, staticBufferData, 0, 0);
			cBuffers.append(d3dStaticBuffer);
		}
		if (d3dObjectBuffer)
		{
			D3DContext->UpdateSubresource(d3dObjectBuffer, 0, nullptr, batchBufferData, 0, 0);
			cBuffers.append(d3dObjectBuffer);
			ResetObjects();
		}
		D3DContext->VSSetConstantBuffers(0, cBuffers.size(), cBuffers.data());
		D3DContext->PSSetConstantBuffers(0, cBuffers.size(), cBuffers.data());

		// Submit vertices
		D3D_PRIMITIVE_TOPOLOGY topo = D3D_PRIMITIVE_TOPOLOGY_UNDEFINED;
		switch (mode)
		{
			case TRIANGLE_LIST: topo = D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST; break;
			case TRIANGLE_STRIP: topo = D3D11_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP; break;
			case LINE_LIST: topo = D3D11_PRIMITIVE_TOPOLOGY_LINELIST; break;
			case LINE_STRIP: topo = D3D11_PRIMITIVE_TOPOLOGY_LINESTRIP; break;
			case POINT_LIST: topo = D3D11_PRIMITIVE_TOPOLOGY_POINTLIST; break;
		}
		D3DContext->IASetInputLayout(d3dInputLayout[vertexFormat]);
		D3DContext->IASetPrimitiveTopology(topo);
		D3DContext->DrawIndexed(numIndices, 0, 0);

		// Reset input
		for (IntType s = 0; s < numSamplers; s++)
		{
			texSamplers[s] = nullptr;
			texSRVs[s] = nullptr;
		}
		D3DContext->PSSetSamplers(0, texSamplers.size(), texSamplers.data());
		D3DContext->PSSetShaderResources(0, texSRVs.size(), texSRVs.data());
	#else
		// Set up attributes
		switch (vertexFormat)
		{
			case PRIMITIVE: PrimitiveVertex::SetAttributes(); break;
			case VERTEX_BUFFER: Vertex::SetAttributes(); break;
			case WORLD: WorldVertex::SetAttributes(); break;
		}

		// Submit UvRects/repeat options
		if (numSamplers > 0)
		{
			program->setUniformValueArray(uvRectUniform.glLocation, samplerUvRect, numSamplers);
			program->setUniformValueArray(texRepeatUniform.glLocation, (GLint*)samplerRepeat, numSamplers);
		}

		// Submit SSBO
		if (useBatching)
		{
			GFX->glBindBuffer(GL_SHADER_STORAGE_BUFFER, glSsboId);
			GFX->glBufferSubData(GL_SHADER_STORAGE_BUFFER, 0, batchBufferObjectIndex * batchBufferObjectSize, batchBufferData);
			GFX->glBindBuffer(GL_SHADER_STORAGE_BUFFER, 0);
			GFX->glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 2, glSsboId);
			GL_CHECK_ERROR();
			ResetObjects();
		}

		// Submit vertices
		GLenum modeEnum = 0;
		switch (mode)
		{
			case TRIANGLE_LIST: modeEnum = GL_TRIANGLES; break;
			case TRIANGLE_STRIP: modeEnum = GL_TRIANGLE_STRIP; break;
			case LINE_LIST: modeEnum = GL_LINES; break;
			case LINE_STRIP: modeEnum = GL_LINE_STRIP; break;
			case POINT_LIST: modeEnum = GL_POINTS; break;
		}
		GFX->glDrawElements(modeEnum, (GLsizei)numIndices, GL_UNSIGNED_INT, 0);
		GL_CHECK_ERROR();
	#endif
	}

	void Shader::ResetObjects()
	{
		if (!useBatching)
			return;

		// Reset to first object
		memcpy(batchBufferData, batchBufferData + batchBufferObjectIndex * batchBufferObjectSize, batchBufferObjectSize);
		batchBufferObjectIndex = 0;
	}

	void Shader::WriteUniformValue(const UniformState& uniform, const void* data, IntType size)
	{
		if (!size)
			size = uniform.totalBufferSize;

		char* dst;
		if (uniform.isStatic)
			dst = staticBufferData;
		else
			dst = batchBufferData + batchBufferObjectIndex * batchBufferObjectSize;

		memcpy(dst + uniform.bufferOffset, data, size);
	}

	void Shader::LoadCodeCommon(QString& code)
	{
		// Replace base texture
		if (code.contains("gm_BaseTexture"))
		{
			code.replace("gm_BaseTexture", "_uBaseTexture");
			code = "uniform sampler2D _uBaseTexture;\n" + code;
			useBaseTexture = true;
		}

		// Replace GM array with new matrix uniforms
		for (IntType m = 0; m < 6; m++)
			if (code.contains(gmMatrixUniformName[m]))
				code.replace(gmMatrixUniformName[m], matrixUniformName[m]);

		// Break apart World*View matrix
		if (useBatching)
		{
		#if API_D3D11
			code.replace(QRegularExpression("\\b_uMatrixMV\\b"), "mul(_uMatrixV, _uMatrixM)");
		#else
			code.replace(QRegularExpression("\\b_uMatrixMV\\b"), "(_uMatrixV * _uMatrixM)");
		#endif
		}

		// Add uniforms for required matrices
		for (IntType m = 0; m < 6; m++)
		{
			if (code.indexOf(QRegularExpression("\\b" + matrixUniformName[m] + "\\b")) > -1)
			{
				BoolType isStatic = true;
				if (useBatching)
					isStatic = (m != MatrixId::M && m != MatrixId::MVP); // Per-object M and MVP
				code = "uniform mat4 " + matrixUniformName[m] + ";" + (isStatic ? " // Static" : "") + "\n" + code;
			}
		}

		// Replace constants with its value in arrays
		auto defIt = QRegularExpression("#define (.*?) (.*?)\n").globalMatch(code);
		while (defIt.hasNext())
		{
			QRegularExpressionMatch match = defIt.next();
			QString name = match.captured(1);
			QString val = match.captured(2);
			code.replace("[" + name + "]", "[" + val + "]");
		}

		// Find uniforms and samplers
		auto uniIt = QRegularExpression("^uniform (\\w*) (.*?)(\\[.*?\\])?;(( \\/\\/ (s|S)tatic)|( \\/\\/.*))?$", QRegularExpression::MultilineOption).globalMatch(code);
		while (uniIt.hasNext())
		{
			QRegularExpressionMatch match = uniIt.next();
			QString name = match.captured(2);
			if (!uniformNameMap.contains(name))
			{
				QString typeName = match.captured(1);
				BoolType isArray = (match.captured(3) != "");
				IntType arrayMaxSize = 1;
				if (isArray)
					arrayMaxSize = match.captured(3).replace(QRegularExpression("\\[|\\]"), "").toInt();
				BoolType isStatic = (match.captured(5) != "");
				AddUniform(name, typeName, isStatic, isArray, arrayMaxSize);
			}

			#if API_D3D11 // Erase uniforms in HLSL, replaced by Cbuffer
				code.replace(match.captured(0) + "\n", "");
			#endif
		}

		// Add uvRect to texture2D calls
		auto texIt = QRegularExpression("texture2D\\((.*?),").globalMatch(code);
		while (texIt.hasNext())
		{
			QRegularExpressionMatch match = texIt.next();
			QString name = match.captured(1);
			if (samplerNameMap.contains(name))
			{
				code.replace("texture2D(" + name + ",",
					"_sampleUvRect(" + name + ", "
				#if API_D3D11
					+ name + "_s, "
				#endif
					"_uUvRect[" + NumStr(samplerNameMap[name]) + "], "
					"_uTexRepeat[" + NumStr(samplerNameMap[name]) + "] > 0,"
				);
			}
			else
				WARNING("Shader: Sampler " + name + " not defined in texture2D call");
		}

		// Object UvRect required when base sampler is used
		if (useBatching && numSamplers > 0)
		{
			if (objRectUniformIndex < 0)
				objRectUniformIndex = AddUniform("_objUvRect", "vec4", false);
			code.replace("_uUvRect[0]", "_objUvRect");
		}
	}

	IntType Shader::AddUniform(QString name, QString typeName, BoolType isStatic, BoolType isArray, IntType arrayMaxSize)
	{
		UniformState uni;
		uni.name = name;
		uni.typeName = typeName;
		uni.type = dataTypeNameMap[uni.typeName];
		uni.isStatic = (isStatic || isArray || uni.type == DataType::SAMPLER2D || !useBatching); // Always static for arrays, samplers and when batching disabled
		uni.isArray = isArray;
		uni.arrayMaxSize = arrayMaxSize;
		uni.bufferSize = dataTypeSizeMap[uni.type];

		if (API_D3D11 && isArray) // Each array element takes up 16 bytes in HLSL (except last)
		{
			uni.bufferSize = (uni.type == DataType::MAT4 ? dataTypeSizeMap[MAT4] : dataTypeSizeMap[VEC4]);
			uni.totalBufferSize = uni.bufferSize * (uni.arrayMaxSize - 1) + dataTypeSizeMap[uni.type];
		}
		else
			uni.totalBufferSize = uni.bufferSize * uni.arrayMaxSize;

		// Get aligned offset in object/static buffer
		if (uni.bufferSize)
		{
			// Get size variable to increase (entire buffer or per object)
			IntType* bufferSize = uni.isStatic ? &staticBufferSize : &batchBufferObjectSize;

		#if API_D3D11
			IntType alignment = 4;
			IntType groupRemainingBytes = 16 - (*bufferSize % 16); // Align into groups of 16 bytes
			if (uni.bufferSize > groupRemainingBytes)
				alignment = 16;
		#else
			// Find alignment in bytes
			IntType alignment = uni.bufferSize;
			if (uni.type == VEC3) // vec3 alignment is same as vec4
				alignment = 16;
		#endif

			// Snap to alignment and increase buffer size (entire buffer or per object)
			uni.bufferOffset = std::ceil((RealType)*bufferSize / alignment) * alignment;
			*bufferSize = uni.bufferOffset + uni.totalBufferSize;
		}

		uniformNameMap[name] = numUniforms;
		uniforms[numUniforms] = uni;

		// Add sampler
		if (uni.type == SAMPLER2D)
			samplerNameMap[name] = numSamplers++;

		// Add matrix
		if (matrixUniformName.contains(name))
		{
			IntType matrixId = matrixUniformName.indexOf(name);
			matrixState[matrixId].active = true;
			matrixState[matrixId].uniform = uni;
		}
		return numUniforms++;
	}

	void Shader::CheckReload()
	{
	#ifdef ASSETS_DIR
		for (Shader* shader : allShaders)
		{
			for (const QString& filename : { shader->vsName, shader->fsName })
			{
				QFileInfo fileInfo(filename);
				QDateTime lastModified = fileInfo.lastModified();
				if (shader->lastUpdate.contains(filename))
				{
					if (fileInfo.size() == 0 ||
						shader->lastUpdate[filename] == lastModified)
						continue;

					GFX->StartOffScreenRender();
					shader->Load(false);

					if (shader->IsLoaded())
						DEBUG("Reloaded " + filename);
				}
				shader->lastUpdate[filename] = lastModified;
			}
		}
	#endif
	}
}
