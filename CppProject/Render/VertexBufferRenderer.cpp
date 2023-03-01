#include "VertexBufferRenderer.hpp"

#include "AppHandler.hpp"
#include "Asset/Shader.hpp"
#include "Asset/VertexBuffer.hpp"
#include "GraphicsApiHandler.hpp"

namespace CppProject
{
	VertexBufferRenderer::VertexBufferRenderer()
	{
		currentBatch = new Batch;
	}

	void VertexBufferRenderer::Add(VertexBuffer* buffer)
	{
		// Empty
		if (buffer->meshes.size() == 0)
			return;

		Mesh<>* mesh = buffer->meshes[0];

		// Max triangles exceeded
		if (currentBatch->numObjects && currentBatch->mesh.numIndices + mesh->numIndices >= MAX_BATCH_INDICES)
			SubmitBatch();

		// Append new object
		currentBatch->objects[currentBatch->numObjects] = buffer->id;
		currentBatch->matrixM[currentBatch->numObjects] = GFX->matrixM;
		currentBatch->bounds.AddBounds(mesh->bounds, GFX->matrixM);
		currentBatch->mesh.numVertices += mesh->numVertices;
		currentBatch->mesh.numIndices += mesh->numIndices;
		currentBatch->numObjects++;

		bool submit = GFX->shader->SubmitObject();
		if (!GFX->shader->useBatching ||
			submit ||
			currentBatch->numObjects >= MAX_BATCH_OBJECTS ||
			currentBatch->mesh.numIndices >= MAX_BATCH_INDICES)
			SubmitBatch();
	}

	void VertexBufferRenderer::SubmitBatch()
	{
		if (!currentBatch->numObjects || !GFX->shader || !GFX->shader->IsLoaded())
			return;

		submitBatch = nullptr;

		// Bind the only submitted vertex buffer if batching is disabled or max triangles was exceeded
		if (currentBatch->numObjects == 1)
		{
			VertexBuffer* buffer = FindVertexBuffer(currentBatch->objects[0]);
			IntType calls = buffer->Submit(GFX->shader, currentBatch->matrixM[0]);
			renderCalls += calls;
			if (calls)
				trianglesSubmitted += buffer->numIndices / 3;
		}
		else
		{
			// Look for identical batches
			for (Batch* frameBatch : activeBatches)
			{
				if (*currentBatch == *frameBatch)
				{
					submitBatch = frameBatch;
					break;
				}
			}

			// Use the current batch
			if (!submitBatch)
			{
				submitBatch = currentBatch;
				submitBatch->CreateBuffers();
				activeBatches.append(submitBatch);
			}

			// Render if within view
			if (GFX->IsVisible(currentBatch->bounds))
			{
				submitBatch->mesh.BeginUse();
				GFX->shader->SubmitVertices(Shader::TRIANGLE_LIST, submitBatch->mesh.numIndices);
				submitBatch->mesh.EndUse();
				renderCalls++;
				trianglesSubmitted += submitBatch->mesh.numIndices / 3;
			}
			else
				GFX->shader->ResetObjects();
		}

		// Mark as active
		if (submitBatch)
			submitBatch->isInCurrentFrame = true;

		// Reset current batch
		if (submitBatch == currentBatch)
			currentBatch = new Batch;
		else
			currentBatch->Reset();
	}

	void VertexBufferRenderer::EndFrame()
	{
		SubmitBatch();

		// Free unused batches
		IntType batchesFreed = 0;
		for (IntType b = 0; b < activeBatches.size(); b++)
		{
			Batch* batch = activeBatches[b];
			if (!batch->isInCurrentFrame)
			{
				delete batch;
				batchesFreed++;
				activeBatches.removeAt(b--);
			}
			else
				batch->isInCurrentFrame = false;
		}

		if (batchesCreated)
			batchesCreated = 0;

		if (batchesCopied)
			batchesCopied = 0;
	}

	VertexBufferRenderer::Batch::~Batch()
	{
		mesh.FreeBuffers();
	}

	bool VertexBufferRenderer::Batch::operator==(const Batch& other) const
	{
		if (numObjects != other.numObjects ||
			mesh.numVertices != other.mesh.numVertices ||
			mesh.numIndices != other.mesh.numIndices)
			return false;

		for (IntType i = 0; i < numObjects; i++)
			if (objects[i] != other.objects[i])
				return false;

		return true;
	}

	void VertexBufferRenderer::Batch::Reset()
	{
		numObjects = 0;
		bounds.Reset();
		mesh.numVertices = mesh.numIndices = 0;
		mesh.FreeBuffers();
	}

	void VertexBufferRenderer::Batch::CreateBuffers()
	{
		mesh.vertexData.Alloc(mesh.numVertices);
		mesh.indexData.Alloc(mesh.numIndices);

		IntType vertexOffset = 0, indexOffset = 0;
		for (IntType objIndex = 0; objIndex < numObjects; objIndex++)
		{
			Mesh<>* objMesh = FindVertexBuffer(objects[objIndex])->meshes[0];
			if (!objMesh->vertexData.Size())
				continue;

			// Copy vertices and assign object index
			memcpy(&mesh.vertexData[vertexOffset], objMesh->vertexData.Data(), objMesh->numVertices * sizeof(Vertex));
			for (IntType v = 0; v < objMesh->numVertices; v++)
				mesh.vertexData[vertexOffset + v].SetIndex(objIndex);

			// Copy indices and apply vertex offset
			for (IntType i = 0; i < objMesh->numIndices; i++)
				mesh.indexData[indexOffset + i] = objMesh->indexData.Value(i) + vertexOffset;

			vertexOffset += objMesh->numVertices;
			indexOffset += objMesh->numIndices;
		}

		mesh.CreateBuffers();
		VB->batchesCreated++;
	}
}