#include "VertexBufferRenderer.hpp"

#include "AppHandler.hpp"
#include "Asset/Shader.hpp"
#include "Asset/VertexBuffer.hpp"
#include "GraphicsApiHandler.hpp"

namespace CppProject
{
	static constexpr IntType MAX_BATCH_CACHE_BYTES = 256 * 1024 * 1024;

	VertexBufferRenderer::VertexBufferRenderer()
	{
		currentBatch = new Batch;
	}

	void VertexBufferRenderer::Add(VertexBuffer* buffer)
	{
		// Offset faces need their original triangulation for zero-bend UV interpolation
		if (buffer->bend.zeroBuffer && buffer->bend.zeroPose)
		{
			VertexBuffer* zeroBuffer = FindVertexBuffer(buffer->bend.zeroBuffer);
			if (zeroBuffer && zeroBuffer->valid && zeroBuffer->completed && zeroBuffer->numIndices)
				buffer = zeroBuffer;
		}

		// Empty
		if (!buffer->valid || !buffer->completed || !buffer->numIndices)
			return;

		auto submitBend = [&]()
		{
			Shader* shader = GFX->shader;
			if (shader->bendUniforms[0] >= 0)
			{
				shader->SubmitVec4(shader->bendUniforms[0], buffer->bend.enabled ? buffer->bend.kind : 0, buffer->bend.sharpAxis, 0, 0);
				if (buffer->bend.enabled)
				{
					shader->SubmitVec3(shader->bendUniforms[1], buffer->bend.angle);
					shader->SubmitVec3(shader->bendUniforms[2], buffer->bend.pivot);
					shader->SubmitVec3(shader->bendUniforms[3], buffer->bend.minimum);
					shader->SubmitVec3(shader->bendUniforms[4], buffer->bend.maximum);
					shader->SubmitVec3(shader->bendUniforms[5], buffer->bend.direction);
					shader->SubmitVec3(shader->bendUniforms[6], buffer->bend.wind);
				}
			}
		};

		if (!buffer->batching)
		{
			SubmitBatch();

			submitBend();

			// Submit vertex buffer directly
			IntType calls = buffer->Submit(GFX->shader, GFX->matrixM);
			renderCalls += calls;
			if (calls)
				trianglesSubmitted += buffer->numIndices / 3;

			return;
		}

		bool instanced = (
			GFX->shader->useBatching &&
			GFX->shader->vertexFormat == Shader::VERTEX_BUFFER &&
			buffer->numIndices >= MAX_BATCH_INDICES
		);

		// Keep batch boundaries stable even when the next large buffer is culled
		if (currentBatch->numObjects &&
			(currentBatch->isInstanced != instanced ||
			(instanced && currentBatch->objects[0] != buffer->id) ||
			(!instanced && currentBatch->mesh.numIndices + buffer->numIndices >= MAX_BATCH_INDICES)))
		{
			SubmitBatch();
		}

		Bounds worldBounds;
		worldBounds.AddBounds(buffer->bounds, GFX->matrixM);

		if (instanced && !GFX->IsVisible(worldBounds))
			return;

		submitBend();

		// Append new object
		currentBatch->objects[currentBatch->numObjects] = buffer->id;
		currentBatch->isInstanced = instanced;
		currentBatch->matrixM[currentBatch->numObjects] = GFX->matrixM;
		currentBatch->bounds.AddBounds(worldBounds);
		currentBatch->mesh.numVertices += buffer->numVertices;
		currentBatch->mesh.numIndices += buffer->numIndices;
		currentBatch->numObjects++;

		bool submit = GFX->shader->SubmitObject();
		if (submit ||
			currentBatch->numObjects >= MAX_BATCH_OBJECTS ||
			(!instanced && currentBatch->mesh.numIndices >= MAX_BATCH_INDICES))
		{
			SubmitBatch();
		}
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
		else if (currentBatch->isInstanced)
		{
			// Re-use the same mesh for all visible instances
			Mesh<>* mesh = FindVertexBuffer(currentBatch->objects[0]);
			mesh->BeginUse();

			GFX->shader->SubmitVertices(Shader::TRIANGLE_LIST, mesh->numIndices, currentBatch->numObjects);
			mesh->EndUse();

			renderCalls++;
			trianglesSubmitted += mesh->numIndices / 3 * currentBatch->numObjects;
		}
		else if (GFX->IsVisible(currentBatch->bounds))
		{
			// Look for identical batches
			for (IntType b = 0; b < activeBatches.size(); b++)
			{
				Batch* frameBatch = activeBatches[b];
				if (*currentBatch == *frameBatch)
				{
					submitBatch = frameBatch;

					// Keep the most recently used batches at the end
					activeBatches.removeAt(b);
					activeBatches.append(frameBatch);
					break;
				}
			}

			// Use the current batch
			if (!submitBatch)
			{
				submitBatch = currentBatch;
				submitBatch->CreateBuffers();

				activeBatches.append(submitBatch);
				cacheBytes += submitBatch->GetSizeBytes();
			}

			submitBatch->mesh.BeginUse();
			GFX->shader->SubmitVertices(Shader::TRIANGLE_LIST, submitBatch->mesh.numIndices);
			submitBatch->mesh.EndUse();

			renderCalls++;
			trianglesSubmitted += submitBatch->mesh.numIndices / 3;
		}
		else
			GFX->shader->ResetObjects();

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

		// Retain batches across idle viewport frames and evict the oldest unused entries first
		for (IntType b = 0; b < activeBatches.size(); b++)
		{
			Batch* batch = activeBatches[b];
			if (!batch->isInCurrentFrame && cacheBytes > MAX_BATCH_CACHE_BYTES)
			{
				cacheBytes -= batch->GetSizeBytes();
				if (submitBatch == batch)
					submitBatch = nullptr;

				delete batch;
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

	void VertexBufferRenderer::Invalidate(IntType buffer)
	{
		// Submit queued geometry while the source buffer is still valid
		if (std::find(currentBatch->objects, currentBatch->objects + currentBatch->numObjects, buffer) !=
			currentBatch->objects + currentBatch->numObjects)
			SubmitBatch();

		for (IntType b = 0; b < activeBatches.size(); b++)
		{
			Batch* batch = activeBatches[b];
			if (std::find(batch->objects, batch->objects + batch->numObjects, buffer) == batch->objects + batch->numObjects)
				continue;

			cacheBytes -= batch->GetSizeBytes();
			if (submitBatch == batch)
				submitBatch = nullptr;

			delete batch;
			activeBatches.removeAt(b--);
		}
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
		isInstanced = false;
		bounds.Reset();

		mesh.numVertices = mesh.numIndices = 0;
		mesh.FreeBuffers();
	}

	void VertexBufferRenderer::Batch::CreateBuffers()
	{
		mesh.vertexData.Alloc(mesh.numVertices);
		mesh.indexData.Alloc(mesh.numIndices);
		bool hasBends = false;
		for (IntType i = 0; i < numObjects; i++)
			hasBends |= FindVertexBuffer(objects[i])->bend.enabled;
		if (hasBends)
			mesh.bendData.Alloc(mesh.numVertices);

		IntType vertexOffset = 0, indexOffset = 0;
		for (IntType objIndex = 0; objIndex < numObjects; objIndex++)
		{
			Mesh<>* objMesh = FindVertexBuffer(objects[objIndex]);
			if (!objMesh->vertexData.Size())
				continue;

			// Copy vertices and assign object index
			memcpy(&mesh.vertexData[vertexOffset], objMesh->vertexData.Data(), objMesh->numVertices * sizeof(Vertex));
			for (IntType v = 0; v < objMesh->numVertices; v++)
				mesh.vertexData[vertexOffset + v].SetObjectIndex(objIndex);

			if (hasBends && objMesh->bendData.Size())
				memcpy(&mesh.bendData[vertexOffset], objMesh->bendData.Data(), objMesh->numVertices * sizeof(BendVertex));

			// Copy indices and apply vertex offset
			for (IntType i = 0; i < objMesh->numIndices; i++)
				mesh.indexData[indexOffset + i] = objMesh->indexData.Value(i) + vertexOffset;

			vertexOffset += objMesh->numVertices;
			indexOffset += objMesh->numIndices;
		}

		mesh.CreateBuffers();

		VB->batchesCreated++;
	}

	IntType VertexBufferRenderer::Batch::GetSizeBytes() const
	{
		return sizeof(Batch) + mesh.numVertices * sizeof(Vertex) + mesh.numIndices * sizeof(uint32_t);
	}
}
