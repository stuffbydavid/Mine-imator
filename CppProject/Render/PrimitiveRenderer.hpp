#pragma once
#include "Vertex.hpp"
#include "FastVector.hpp"
#include "Asset/Shader.hpp"

namespace CppProject
{
	struct Shader;
	struct Font;

	// Stores a batch of primitives and submits them to the GPU when needed.
	struct PrimitiveRenderer
	{
		PrimitiveRenderer();

		// Starts drawing a primitive shape.
		void Begin(IntType mode = 0, IntType texture = 0, QTransform transform = QTransform());

		// Adds a new vertex.
		void Add(PrimitiveVertex vertex);

		// Submits all the queued primitive shapes to the GPU.
		void SubmitBatch();

		// Returns the primitive shader.
		static Shader* GetShader() { return prShader; }

		IntType mode = 0;
		Shader::RenderMode renderMode = Shader::NO_MODE;
		FastVector<PrimitiveVertex> vertices;
		FastVector<uint32_t> indices;
		UvRect uvRect;
		QTransform transform;
		IntType beginIndex = 0;
		IntType currentIndex = 0;
		RealType depth = 0.0;

	#if API_D3D11
		ID3D11Buffer* d3dVertexBuffer = nullptr;
		ID3D11Buffer* d3dIndexBuffer = nullptr;
	#else
		QOpenGLBuffer* glVertexBuffer = nullptr;
		QOpenGLBuffer* glIndexBuffer = nullptr;
	#endif
		IntType vertexBufferSize = 0, indexBufferSize = 0;

		QColor color = Qt::black;
		Font* font = nullptr;
		IntType halign = 0;
		IntType valign = 0;

		IntType renderCalls = 0;
		IntType linesSubmitted = 0;
		IntType trianglesSubmitted = 0;

		static Shader* prShader;
	};
}