#pragma once
#include "Asset.hpp"
#include "Render/Matrix.hpp"
#include "Render/GraphicsApiHandler.hpp"
#include "Type/VecType.hpp"

#if API_OPENGL
#include <QOpenGLShaderProgram>
#include <QOpenGLFunctions_4_3_Core>
#endif
#include <QVector4D>

// Maximum allowed size of batch buffer in bytes
#if API_D3D11
#define MAX_BATCH_BUFFER_SIZE (4096 * 16) // 4096 float4s (64kb)
#else
#define MAX_BATCH_BUFFER_SIZE (100 * 1024) // 100kb
#endif

namespace CppProject
{
	struct TexturePage;
	struct VarType;

	// Shader asset that can be converted from GLSL ES 1.0 with uniforms converted into SSBOs.
	struct Shader : Asset
	{
		enum VertexFormat : int;
		enum MatrixId : int;
		enum DataType : int;
		enum RenderMode : int;

		Shader(QString name, IntType subAssetId);
		Shader(QString name, VertexFormat format, BoolType useBatching = false);

		// Loads the vertex & fragment shader from filesystem or memory.
		void Load(BoolType useCache = true);
		void LoadCode(QString vsCode, QString fsCode, BoolType useCache);
		void LoadCodeCommon(QString& code);

		// Returns whether the shader is successfully loaded.
		BoolType IsLoaded() const;

		// Starts/stops using the shader, returns whether successful.
		bool BeginUse();
		bool EndUse();

		// Returns the index of an uniform with the given name.
		IntType GetUniformIndex(StringType name) { return uniformNameMap.value(name, -1); }

		// Returns the index of a sampler with the given name.
		IntType GetSamplerIndex(StringType name) { return samplerNameMap.value(name, -1); }

		// Submit an uniform value to the shader.
		// Static uniforms are sent immediately (or all when SSBO is disabled), others are buffered.
		void SubmitInt(IntType index, int32_t in);
		void SubmitFloat(IntType index, float fl);
		void SubmitFloatArray(IntType index, VarType& arrOrMatrix);
		void SubmitVec2(IntType index, float x, float y);
		inline void SubmitVec2(IntType index, const VecType& vec) { SubmitVec2(index, vec.x, vec.y); }
		void SubmitVec3(IntType index, float x, float y, float z);
		inline void SubmitVec3(IntType index, const VecType& vec) { SubmitVec3(index, vec.x, vec.y, vec.z); }
		void SubmitVec4(IntType index, float x, float y, float z, float w);
		inline void SubmitVec4(IntType index, const VecType& vec) { SubmitVec4(index, vec.x, vec.y, vec.z, vec.z); }
		void SubmitMat4(IntType index, const Matrix& matrix);
		void SubmitMat4Array(IntType index, ArrType arr);

		// Submits an QOpenGLTexture/TexturePageLocation ID to a sampler with the given index.
		// Returns the UV rectangle to transform vertices by if getUvRect is enabled, otherwise this is done in the shader.
		// If the sampler value changes, the current batch is submitted.
		UvRect SubmitTexture(StringType samplerName, IntType id, bool getUvRect = false);
		UvRect SubmitTexture(IntType sampler, IntType id, bool getUvRect = false);

		// Update a matrix in the shader.
		void SubmitMatrix(MatrixId matrix, const Matrix& value, BoolType clearMvpMatrices = false);

		// Marks the submitted uniforms as complete and copies their values to the next object.
		// Returns whether the maximum amount of objects allowed has been reached.
		bool SubmitObject();

		// Submit a number of previously bound vertices and indices for rendering.
		void SubmitVertices(RenderMode mode, IntType numIndices);

		// Resets the current batch of objects, called when SubmitVertices is skipped for culling.
		void ResetObjects();

		// Write a uniform value of the current object to the buffer.
		struct UniformState;
		void WriteUniformValue(const UniformState& uniform, const void* data, IntType size = 0);

		// Adds a new uniform to the shader, returning its index.
		IntType AddUniform(QString name, QString typeName, BoolType isStatic, BoolType isArray = false, IntType arrayMaxSize = 1);

		// Find the supported GLSL version on the system.
		static void Init();

		// Checks if any shader needs to be reloaded.
		static void CheckReload();

		// The format of vertices sent into the shader.
		enum VertexFormat : int
		{
			UNKNOWN, PRIMITIVE, VERTEX_BUFFER, WORLD
		};

		// The matrices available in the shader.
		// When the buffer is enabled in the shader, M is replaced with M[objectIndex] for MVP, MV and M.
		enum MatrixId : int
		{
			MVP, VP, MV, M, V, P
		};

		// Data type for uniforms.
		enum DataType : int
		{
			INT, FLOAT, VEC2, VEC3, VEC4, MAT4, SAMPLER2D
		};

		// Render mode for submitted vertices.
		enum RenderMode : int
		{
			NO_MODE = 0, TRIANGLE_LIST, TRIANGLE_STRIP, LINE_LIST, LINE_STRIP, POINT_LIST
		};

		VertexFormat vertexFormat = UNKNOWN;
		QString name, vsName, fsName;
		QHash<QString, QDateTime> lastUpdate;
		IntType attributeLocation[6], numOutputs = 0;

	#if API_D3D11
		ID3D11VertexShader* d3dVertexShader = nullptr;
		ID3D11PixelShader* d3dPixelShader = nullptr;
		ID3D11Buffer* d3dObjectBuffer = nullptr;
		ID3D11Buffer* d3dStaticBuffer = nullptr;
		static ID3D11InputLayout* d3dInputLayout[4];
	#else
		QOpenGLShaderProgram* program = nullptr;
		GLuint glSsboId, glSsboBlockIndex;
	#endif

		// Whether batching is supported for objects (requires Direct3D 11/OpenGL 4.3+)
		BoolType useBatching = false;

		// Buffer info
		char* batchBufferData = nullptr;
		char* staticBufferData = nullptr;
		IntType batchBufferSize = 0;
		IntType staticBufferSize = 0;
		IntType batchBufferObjectIndex = 0;
		IntType batchBufferObjectSize = 0;
		IntType batchBufferMaxObjects = 0;

		// Uniform info
		QHash<StringType, IntType> uniformNameMap; // name->index in uniforms list
		QHash<IntType, IntType> uniformLocationMap; // location->index in uniforms list
		struct UniformState
		{
			QString name, typeName;
			DataType type;
			BoolType isArray = false;
			IntType arrayMaxSize = 0;
			BoolType isStatic = true;
			IntType bufferOffset, bufferSize, totalBufferSize;
		#if API_OPENGL
			IntType glLocation = -1;
		#endif
		};
		QHash<IntType, UniformState> uniforms;
		IntType numUniforms = 0;
		IntType objRectUniformIndex = -1;

		// Sampler info
		struct SamplerState
		{
			IntType currentTexId = -1;
			BoolType filter = false;
			BoolType mipMap = false;
			BoolType changed = false;
		#if API_OPENGL
			IntType glLocation = -1;
		#endif
		};
		SamplerState samplerState[32];
		QVector4D samplerUvRect[32];
		int32_t samplerRepeat[32];
	#if API_D3D11
		int32_t* samplerRepeatData = nullptr;
		IntType samplerRepeatDataSize = 0;
	#endif
		QHash<StringType, IntType> samplerNameMap; // name->index in samplerState
		IntType numSamplers = 0;
		BoolType useBaseTexture = false;
		UniformState uvRectUniform;
		UniformState texRepeatUniform;

		// Matrix info
		struct MatrixState
		{
			BoolType active = false;
			Matrix current;
			BoolType changed = false;
			UniformState uniform;
		};
		MatrixState matrixState[6];

		static QVector<Shader*> allShaders;
		static TexturePage* currentPage;
		static QMap<QString, DataType> dataTypeNameMap;
		static QMap<DataType, IntType> dataTypeSizeMap;
		static QStringList matrixUniformName;
		static QStringList gmMatrixUniformName;

	#if API_D3D11
		static QMap<DataType, QString> dataTypeD3D11Map;
	#else
		static QString glslVersion;
		static BoolType gl40Supported; // Required for textureQueryLod
		static BoolType gl43Supported; // Required for SSBO
		static QOpenGLFunctions_4_3_Core* gl43Core;
	#endif
	};
}
