#pragma once
#include "Asset/Shader.hpp"
#include "Asset/VertexBuffer.hpp"
#include "Type/MatrixType.hpp"

#define MAX_BATCH_OBJECTS 1024
#define MAX_BATCH_TRIANGLES 20000
#define MAX_BATCH_INDICES MAX_BATCH_TRIANGLES * 3

namespace CppProject
{
	struct VertexBuffer;

	// Stores a batch of vertex buffers and submits them to the GPU when needed.
	// Cached batches are retained across frames that reuse viewport surfaces.
	struct VertexBufferRenderer
	{
		VertexBufferRenderer();

		// Adds an object to the queue with the current uniform settings.
		void Add(VertexBuffer* buffer);

		// Submits all the queued objects for rendering.
		void SubmitBatch();

		// Evicts unused batches when the cache exceeds its memory budget.
		void EndFrame();

		// Flush pending draws and remove cached batches before a source buffer changes or is destroyed.
		void Invalidate(IntType buffer);

		// A list of objects to be rendered.
		struct Batch
		{
			~Batch();

			// Returns whether the batch matches another.
			bool operator==(const Batch& other) const;

			// Reset the batch for continued usage.
			void Reset();

			// Creates and binds vertex and index buffers.
			void CreateBuffers();

			// Returns the batch size in bytes.
			IntType GetSizeBytes() const;

			IntType objects[MAX_BATCH_OBJECTS];
			Matrix matrixM[MAX_BATCH_OBJECTS];
			IntType numObjects = 0;
			Mesh<> mesh;
			Bounds bounds;
			bool isInCurrentFrame = false;
			bool isInstanced = false;
		};

		Batch* currentBatch = nullptr;
		Batch* submitBatch = nullptr;

		QVector<Batch*> activeBatches;
		IntType cacheBytes = 0;

		IntType renderCalls = 0;
		IntType batchesCreated = 0;
		IntType batchesCopied = 0;
		IntType trianglesSubmitted = 0;
	};
}
