#include "VertexBuffer.hpp"
#include "AppHandler.hpp"
#include "Shader.hpp"
#include "Render/VertexBufferRenderer.hpp"

#undef slots
#undef emit
#define TINYBVH_IMPLEMENTATION
#include "tinybvh/tiny_bvh.h"
#undef TINYBVH_IMPLEMENTATION

#include <QIODevice>

namespace CppProject
{
	VertexBuffer::VertexBuffer(QDataStream& stream, BoolType batching) : VertexBuffer()
	{
		valid = false;
		this->batching = batching;

		qint64 numVert = 0, numInd = 0;
		stream >> numVert;
		stream >> numInd;

		// Validate counts before calculating byte sizes
		QIODevice* device = stream.device();
		if (stream.status() != QDataStream::Ok || device == nullptr || numVert < 0 || numInd < 0)
			return;

		qint64 vertexBytes = numVert * sizeof(Vertex);
		qint64 indexBytes = numInd * sizeof(uint32_t);
		if (vertexBytes + indexBytes > device->bytesAvailable())
			return;

		if (numInd > 0)
		{
			// Read vertices and indices before creating GPU buffers
			vertexData.Alloc(numVert, false);
			indexData.Alloc(numInd, false);
			if (stream.readRawData((char*)vertexData.data, (int)vertexBytes) != vertexBytes ||
				stream.readRawData((char*)indexData.data, (int)indexBytes) != indexBytes)
			{
				WARNING("readRawData error");
				return;
			}

			for (IntType i = 0; i < numInd; i++)
				if (indexData[i] >= numVert)
					return;

			numVertices = numVert;
			numIndices = numInd;
			bounds = Bounds(vertexData);

			CreateBuffers(false);
		}

		completed = true;
		valid = true;

		BuildBVH();
	}

	VertexBuffer::~VertexBuffer()
	{
		if (completed && App && VB)
			VB->Invalidate(id);
	}

	IntType VertexBuffer::Submit(Shader* shader, Matrix boundsTransform)
	{
		if (!valid || !numIndices || !HasBuffers())
			return 0;

		Bounds worldBounds;
		worldBounds.AddBounds(bounds, boundsTransform);

		if (!GFX->IsVisible(worldBounds))
		{
			shader->ResetObjects();
			return 0;
		}

		BeginUse();
		shader->SubmitVertices(Shader::TRIANGLE_LIST, numIndices);
		EndUse();

		return 1;
	}

	Vertex& VertexBuffer::GetCurrentVertex(IntType elementIndex, IntType threadId)
	{
		ThreadData& thread = threads[threadId];

		// Begin new vertex
		if (thread.elemAdded[elementIndex])
		{
			for (IntType el = 0; el < 4; el++)
				thread.elemAdded[el] = false;

			AddVertex(thread.currentVertex, threadId);
			thread.currentVertex = Vertex();
		}

		thread.elemAdded[elementIndex] = true;

		return thread.currentVertex;
	}

	void VertexBuffer::ThreadData::Reserve(IntType addedVertices, IntType addedIndices)
	{
		// Double mesh capacity before appending a complete primitive
		if (vertices.Size() + addedVertices > vertices.heap.Size())
			vertices.heap.Alloc(std::max(vertices.Size() + addedVertices, std::max<IntType>(1024, vertices.heap.Size() * 2)), false);

		if (indices.Size() + addedIndices > indices.heap.Size())
			indices.heap.Alloc(std::max(indices.Size() + addedIndices, std::max<IntType>(1024, indices.heap.Size() * 2)), false);
	}

	void VertexBuffer::AddVertex(const Vertex& vertex, IntType threadId)
	{
		ThreadData& thread = threads[threadId];

		thread.Reserve(1, 1);

		// Check if already added in current face
		IntType i = 0;
		for (IntType v = thread.vertices.Size() - 1; v >= 0; v--)
		{
			if (i++ > 6)
				break;

			if (thread.vertices.Value(v) == vertex)
			{
				thread.indices.Append(v);
				return;
			}
		}

		thread.indices.Append(thread.vertices.Size());
		thread.vertices.Append(vertex);
	}

	void VertexBuffer::AddTriangle(const Vertex& v1, const Vertex& v2, const Vertex& v3, IntType threadId)
	{
		ThreadData& thread = threads[threadId];

		thread.Reserve(3, 3);

		// Create triangle
		IntType vertOffset = thread.vertices.Size();
		thread.indices.Append(vertOffset + 0);
		thread.indices.Append(vertOffset + 1);
		thread.indices.Append(vertOffset + 2);
		thread.vertices.Append(v1);
		thread.vertices.Append(v2);
		thread.vertices.Append(v3);
	}

	void VertexBuffer::AddBendTriangle(const Vertex* vertices, const BendVertex* bends)
	{
		AddTriangle(vertices[0], vertices[1], vertices[2]);
		ThreadData& thread = threads[0];
		if (thread.bends.Size() + 3 > thread.bends.heap.Size())
			thread.bends.heap.Alloc(std::max<IntType>(1024, std::max(thread.bends.Size() + 3, thread.bends.heap.Size() * 2)), false);
		for (int i = 0; i < 3; i++)
			thread.bends.Append(bends[i]);
	}

	void VertexBuffer::AddFace(const Vertex& v1, const Vertex& v2, const Vertex& v3, const Vertex& v4, IntType threadId)
	{
		ThreadData& thread = threads[threadId];

		thread.Reserve(4, 6);

		// Create face
		IntType vertOffset = thread.vertices.Size();
		thread.indices.Append(vertOffset + 0);
		thread.indices.Append(vertOffset + 1);
		thread.indices.Append(vertOffset + 2);
		thread.indices.Append(vertOffset + 2);
		thread.indices.Append(vertOffset + 3);
		thread.indices.Append(vertOffset + 0);
		thread.vertices.Append(v1);
		thread.vertices.Append(v2);
		thread.vertices.Append(v3);
		thread.vertices.Append(v4);
	}

	void VertexBuffer::Complete(BoolType updateTangents)
	{
		if (completed)
		{
			WARNING("Buffer already completed");
			return;
		}

		// Assign each thread a non-overlapping range in the final mesh
		IntType numThreads = 0;
		for (IntType t = 0; t < OPENMP_MAX_THREADS; t++)
		{
			ThreadData& thread = threads[t];

			// Complete current vertex
			for (IntType el = 0; el < 4; el++)
			{
				if (thread.elemAdded[el])
				{
					AddVertex(thread.currentVertex, t);
					break;
				}
			}

			thread.targetVertexOffset = numVertices;
			thread.targetIndexOffset = numIndices;
			numVertices += thread.vertices.Size();
			numIndices += thread.indices.Size();

			if (thread.indices.Size())
				numThreads = t + 1;
		}

		completed = true;
		if (!numIndices)
			return;

		// Keep allocation sizes compatible with GPU buffers and cache serialization
		if (numVertices > std::numeric_limits<int>::max() / sizeof(Vertex) ||
			(bend.enabled && numVertices > std::numeric_limits<int>::max() / sizeof(BendVertex)) ||
			numIndices > std::numeric_limits<int>::max() / sizeof(uint32_t))
		{
			valid = false;
			WARNING("Vertex buffer is too large");
			return;
		}

		// Every element is filled by the thread copies below
		vertexData.Alloc(numVertices, false);
		indexData.Alloc(numIndices, false);
		if (bend.enabled)
			bendData.Alloc(numVertices, false);

		auto processThread = [&](IntType t)
		{
			ThreadData& thread = threads[t];
			if (!thread.indices.Size())
				return;

			// Copy vertices and adjust indices to the combined vertex array
			memcpy(vertexData.data + thread.targetVertexOffset, thread.vertices.Data(), thread.vertices.SizeInBytes());
			if (thread.targetVertexOffset == 0)
				memcpy(indexData.data + thread.targetIndexOffset, thread.indices.Data(), thread.indices.SizeInBytes());
			else
				for (IntType i = 0; i < thread.indices.Size(); i++)
					indexData[thread.targetIndexOffset + i] = thread.indices.Value(i) + thread.targetVertexOffset;

			if (bend.enabled)
				memcpy(bendData.data + thread.targetVertexOffset, thread.bends.Data(), thread.bends.SizeInBytes());
			thread.bends.Clear();
			thread.vertices.Clear();
			thread.indices.Clear();
		};

		if (numThreads > 1)
		{
			#pragma omp parallel for schedule(static)
			for (IntType t = 0; t < numThreads; t++)
				processThread(t);
		}
		else
			processThread(0);

		// Calculate tangent vector for each triangle
		if (updateTangents)
		{
			for (IntType i = 0; i < numIndices / 3; i++)
			{
				Vertex& v1 = vertexData[indexData.Value(i * 3)];
				Vertex& v2 = vertexData[indexData.Value(i * 3 + 1)];
				Vertex& v3 = vertexData[indexData.Value(i * 3 + 2)];

				VecType edge1 = { v2.x - v1.x, v2.y - v1.y, v2.z - v1.z };
				VecType edge2 = { v3.x - v1.x, v3.y - v1.y, v3.z - v1.z };

				VecType deltaUv1 = { v2.u - v1.u, v2.v - v1.v };
				VecType deltaUv2 = { v3.u - v1.u, v3.v - v1.v };

				RealType f = 1.0 / (deltaUv1.x * deltaUv2.y - deltaUv1.y * deltaUv2.x);
				VecType t = ((edge1 * deltaUv2.y - edge2 * deltaUv1.y) * f).GetNormalized();

				v1.SetTangent(t.x, t.y, t.z);
				v2.SetTangent(t.x, t.y, t.z);
				v3.SetTangent(t.x, t.y, t.z);
			}
		}

		bounds = Bounds(vertexData);
		if (bend.enabled)
		{
			// Enclose every bend rotation and the maximum pinch/anti-Z-fighting scale
			RealType radius = 0;
			for (IntType i = 0; i < numVertices; i++)
			{
				const Vertex& v = vertexData.Value(i);
				radius = std::max(radius, (VecType(v.x, v.y, v.z) - bend.pivot).GetLength());
			}
			radius *= 1.406;
			bounds = Bounds(bend.pivot - VecType(radius, radius, radius), bend.pivot + VecType(radius, radius, radius));
		}

		CreateBuffers(false);

		BuildBVH();
	}

	void VertexBuffer::BuildBVH()
	{
		if (!valid || !completed || numIndices < 3)
		{
			bvh = tinybvh::BVH();
			return;
		}

		tinybvh::bvhvec4slice vertices((const tinybvh::bvhvec4*)vertexData.Data(), (uint32_t)numVertices, sizeof(Vertex));
		bvh.Build(vertices, indexData.Data(), (uint32_t)(numIndices / 3));
	}

	void VertexBuffer::Write(QDataStream& stream)
	{
		if (!valid)
		{
			stream << (qint64)0 << (qint64)0;
			return;
		}

		stream << (qint64)numVertices;
		stream << (qint64)numIndices;
		if (!numIndices)
			return;

		stream.writeRawData((const char*)vertexData.Data(), (int)(numVertices * sizeof(Vertex)));
		stream.writeRawData((const char*)indexData.Data(), (int)(numIndices * sizeof(uint32_t)));
	}

	IntType VertexBuffer::GetWriteBytes() const
	{
		IntType bytes = sizeof(qint64) * 2; // numVertices + numIndices
		if (valid && numIndices > 0)
			bytes += numVertices * sizeof(Vertex) + numIndices * sizeof(uint32_t);

		return bytes;
	}
}
