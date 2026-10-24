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
		// Offset faces need their original triangulation for zero-bend UV interpolation
		if (buffer->bend.zeroBuffer && buffer->bend.zeroPose)
		{
			VertexBuffer* zeroBuffer = FindVertexBuffer(buffer->bend.zeroBuffer);
			if (zeroBuffer && zeroBuffer->valid && zeroBuffer->meshes.size())
				buffer = zeroBuffer;
		}

		// Empty
		if (!buffer->valid || buffer->meshes.size() == 0)
			return;

		Mesh<>* mesh = buffer->meshes[0];
		bool instanced = (
			GFX->shader->useBatching &&
			GFX->shader->vertexFormat == Shader::VERTEX_BUFFER &&
			buffer->meshes.size() == 1 &&
			mesh->numIndices >= MAX_BATCH_INDICES
		);

		Bounds worldBounds;
		worldBounds.AddBounds(mesh->bounds, GFX->matrixM);

		if (instanced && !GFX->IsVisible(worldBounds))
			return;

		// Flush incompatible batches or combined meshes over the size limit
		if (currentBatch->numObjects &&
			(currentBatch->isInstanced != instanced ||
			(instanced && currentBatch->objects[0] != buffer->id) ||
			(!instanced && currentBatch->mesh.numIndices + mesh->numIndices >= MAX_BATCH_INDICES)))
		{
			SubmitBatch();
		}

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

		// Append new object
		currentBatch->objects[currentBatch->numObjects] = buffer->id;
		currentBatch->isInstanced = instanced;
		currentBatch->matrixM[currentBatch->numObjects] = GFX->matrixM;
		currentBatch->bounds.AddBounds(worldBounds);
		currentBatch->mesh.numVertices += mesh->numVertices;
		currentBatch->mesh.numIndices += mesh->numIndices;
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
			Mesh<>* mesh = FindVertexBuffer(currentBatch->objects[0])->meshes[0];
			mesh->BeginUse();

			GFX->shader->SubmitVertices(Shader::TRIANGLE_LIST, mesh->numIndices, currentBatch->numObjects);
			mesh->EndUse();

			renderCalls++;
			trianglesSubmitted += mesh->numIndices / 3 * currentBatch->numObjects;
		}
		else if (GFX->IsVisible(currentBatch->bounds))
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

		// Free unused batches
		for (IntType b = 0; b < activeBatches.size(); b++)
		{
			Batch* batch = activeBatches[b];
			if (!batch->isInCurrentFrame)
			{
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
			Mesh<>* objMesh = FindVertexBuffer(objects[objIndex])->meshes[0];
			if (!objMesh->vertexData.Size())
				continue;

			// Copy vertices and assign object index
			memcpy(&mesh.vertexData[vertexOffset], objMesh->vertexData.Data(), objMesh->numVertices * sizeof(Vertex));
			for (IntType v = 0; v < objMesh->numVertices; v++)
				mesh.vertexData[vertexOffset + v].SetIndex(objIndex);

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
}
