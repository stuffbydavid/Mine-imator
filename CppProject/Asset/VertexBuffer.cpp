#include "VertexBuffer.hpp"
#include "AppHandler.hpp"
#include "Shader.hpp"
#include "Render/VertexBufferRenderer.hpp"

#include "Generated/Scripts.hpp"

#undef slots
#undef emit
#define TINYBVH_IMPLEMENTATION
#include "tinybvh/tiny_bvh.h"
#undef TINYBVH_IMPLEMENTATION

#include <QIODevice>

namespace CppProject
{
	static BoolType SameTriangleVertex(const Vertex& a, const Vertex& b)
	{
		// Ignore derived tangents and runtime animation/emissive flags when matching model geometry
		return (a.x == b.x && a.y == b.y && a.z == b.z && a.u == b.u && a.v == b.v && a.data1 == b.data1);
	}

	static BoolType SameTriangle(const Vertex* triangle, const Vertex& v1, const Vertex& v2, const Vertex& v3)
	{
		return SameTriangleVertex(triangle[0], v1) &&
			   SameTriangleVertex(triangle[1], v2) &&
			   SameTriangleVertex(triangle[2], v3);
	}

	static quint64 TriangleHash(const Vertex& v1, const Vertex& v2, const Vertex& v3)
	{
		quint64 hash = 0;
		const Vertex* vertices[] = { &v1, &v2, &v3 };
		for (const Vertex* vertex : vertices)
		{
			quint64 part = 14695981039346656037ull;
			float components[] = { vertex->x, vertex->y, vertex->z, vertex->u, vertex->v };
			for (float value : components)
			{
				uint32_t bits = 0;
				if (value != 0) // Normalize negative zero to match float equality
					memcpy(&bits, &value, sizeof(bits));
				
				part = (part ^ bits) * 1099511628211ull;
			}
			
			hash += (part ^ vertex->data1) * 1099511628211ull;
		}

		return hash;
	}

	VertexBuffer::VertexBuffer(QDataStream& stream, BoolType batching) : VertexBuffer()
	{
		valid = false;
		this->batching = batching;

		qint64 numVert = 0, numInd = 0;
		stream >> numVert;
		stream >> numInd;

		// Validate counts before calculating byte sizes
		QIODevice* device = stream.device();
		if (stream.status() != QDataStream::Ok || device == nullptr || numVert < 0 || numInd < 0 || numInd % 3 != 0)
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

			quint8 hasBlockPositions = 0;
			stream >> hasBlockPositions;
			if (stream.status() != QDataStream::Ok || hasBlockPositions > 1)
				return;

			if (hasBlockPositions)
			{
				qint32 xx = 0, yy = 0, zz = 0;
				stream >> xx >> yy >> zz;
				blockPosOrigin = { xx, yy, zz };

				qint64 bytes = numInd / 3 * sizeof(uint32_t);
				if (stream.status() != QDataStream::Ok || bytes > device->bytesAvailable())
					return;

				triangleBlockPos.Alloc(numInd / 3, false);
				if (stream.readRawData((char*)triangleBlockPos.data, (int)bytes) != bytes)
					return;
			}

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
		if (!valid || !completed || !numIndices || !HasBuffers())
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
				
				if (thread.indices.Size() % 3 == 0)
					thread.AddBlockPos({}, 1);
				
				return;
			}
		}

		thread.indices.Append(thread.vertices.Size());
		thread.vertices.Append(vertex);

		if (thread.indices.Size() % 3 == 0)
			thread.AddBlockPos({}, 1);
	}

	void VertexBuffer::AddTriangle(const Vertex& v1, const Vertex& v2, const Vertex& v3, IntType threadId, BlockPos blockPos)
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
		thread.AddBlockPos(blockPos, 1);
	}

	void VertexBuffer::RemoveTriangle(const Vertex& v1, const Vertex& v2, const Vertex& v3, BlockPos blockPos)
	{
		if (!valid || !numIndices)
			return;

		if (triangleRemovals.isEmpty())
		{
			if (App && VB)
				VB->Invalidate(id);

			completed = false;
		}

		QVector<TriangleRemoval>& matches = triangleRemovals[TriangleHash(v1, v2, v3)];
		for (TriangleRemoval& match : matches)
		{
			if (match.blockPos == blockPos && SameTriangle(match.vertices, v1, v2, v3))
			{
				match.count++;
				return;
			}
		}

		matches.append(TriangleRemoval{ { v1, v2, v3 }, blockPos, 1 });

		triangleRemovalBounds.AddPoint({ v1.x, v1.y, v1.z });
		triangleRemovalBounds.AddPoint({ v2.x, v2.y, v2.z });
		triangleRemovalBounds.AddPoint({ v3.x, v3.y, v3.z });
	}

	void VertexBuffer::AddFace(const Vertex& v1, const Vertex& v2, const Vertex& v3, const Vertex& v4, IntType threadId, BlockPos blockPos)
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
		thread.AddBlockPos(blockPos, 2);
	}

	BlockPos VertexBuffer::GetTriangleBlockPos(IntType index) const
	{
		if (!triangleBlockPos.Size())
			return {};

		// Decode the triangle's block position relative to this vertex buffer's origin
		return { triangleBlockPos.Value(index), blockPosOrigin };
	}

	Bounds VertexBuffer::FitBounds(const VecType& blockPos) const
	{
		BlockPos pos(blockPos);
		BlockBounds bounds(pos);

		AddBlockBounds(pos, bounds);

		return bounds.Fit();
	}

	void VertexBuffer::AddBlockBounds(const BlockPos& blockPos, BlockBounds& bounds) const
	{
		Bounds& blockBounds = bounds.blockBounds;

		for (IntType i = 0; i < numIndices; i += 3)
		{
			BlockPos pos = GetTriangleBlockPos(i / 3);
			if (pos.IsValid() && !(pos == blockPos))
				continue;

			if (pos.doubleBlock)
				blockBounds.AddBounds(pos.GetBounds());

			Bounds triangleBounds;
			for (IntType v = 0; v < 3; v++)
			{
				const Vertex& vertex = vertexData.Value(indexData.Value(i + v));
				triangleBounds.AddPoint({ vertex.x, vertex.y, vertex.z });
			}

			if (!triangleBounds.Intersects(blockBounds))
				continue;

			bounds.triangleBounds.AddBounds(triangleBounds);

			// Unpack normal
			uint32_t normal = vertexData.Value(indexData.Value(i)).data1;
			for (IntType axis = 0; axis < 3; axis++)
			{
				uint8_t component = (normal >> (axis * 8)) & 255;
				if (component > 128)
					bounds.faces |= 1 << (axis * 2);
				else if (component < 127)
					bounds.faces |= 1 << (axis * 2 + 1);
			}
		}
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
		IntType existingTriangles = numIndices / 3;
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
			numIndices > std::numeric_limits<int>::max() / sizeof(uint32_t))
		{
			valid = false;
			WARNING("Vertex buffer is too large");
			return;
		}

		// Every element is filled by the thread copies below
		vertexData.Alloc(numVertices, false);
		indexData.Alloc(numIndices, false);

		PrepareBlockPositions(existingTriangles, numIndices / 3);

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

			CopyBlockPositions(thread, thread.targetIndexOffset / 3);

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

		if (updateTangents)
			UpdateTangents();

		bounds = Bounds(vertexData);

		CreateBuffers(false);

		BuildBVH();
	}

	void VertexBuffer::UpdateTangents(IntType firstIndex)
	{
		for (IntType i = firstIndex / 3; i < numIndices / 3; i++)
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
		stream << quint8(triangleBlockPos.Size() > 0);
		if (triangleBlockPos.Size())
		{
			stream << qint32(blockPosOrigin.x) << qint32(blockPosOrigin.y) << qint32(blockPosOrigin.z);
			stream.writeRawData((const char*)triangleBlockPos.Data(), (int)triangleBlockPos.SizeInBytes());
		}
	}

	IntType VertexBuffer::GetWriteBytes() const
	{
		IntType bytes = sizeof(qint64) * 2; // numVertices + numIndices
		if (valid && numIndices > 0)
		{
			bytes += numVertices * sizeof(Vertex) + numIndices * sizeof(uint32_t) + sizeof(quint8);
			if (triangleBlockPos.Size())
				bytes += sizeof(qint32) * 3 + triangleBlockPos.SizeInBytes();
		}

		return bytes;
	}

	VertexBuffer* VertexBuffer::Copy() const
	{
		if (!valid || !completed)
			return nullptr;

		VertexBuffer* copy = new VertexBuffer;
		copy->batching = batching;
		copy->numVertices = numVertices;
		copy->numIndices = numIndices;
		copy->bounds = bounds;
		copy->blockPosOrigin = blockPosOrigin;
		
		if (triangleBlockPos.Size())
			copy->triangleBlockPos.Copy(triangleBlockPos, triangleBlockPos.Size());
		
		if (numVertices)
			copy->vertexData.Copy(vertexData, numVertices);
		
		if (numIndices)
			copy->indexData.Copy(indexData, numIndices);

		return copy;
	}

	void VertexBuffer::UpdateBuffers()
	{
		if (!valid)
			return;

		if (App && VB)
			VB->Invalidate(id);

		// Match only retained triangles, before appending their replacements
		ApplyTriangleRemovals();

		// Append regenerated primitives without uploading an intermediate buffer
		IntType firstIndex = numIndices;
		IntType totalIndices = numIndices;
		for (const ThreadData& thread : threads)
			totalIndices += thread.indices.Size();

		PrepareBlockPositions(numIndices / 3, totalIndices / 3);

		for (ThreadData& thread : threads)
		{
			if (!thread.indices.Size())
				continue;

			vertexData.Alloc(numVertices + thread.vertices.Size(), false);
			indexData.Alloc(numIndices + thread.indices.Size(), false);
			memcpy(vertexData.data + numVertices, thread.vertices.Data(), thread.vertices.SizeInBytes());
			
			for (IntType i = 0; i < thread.indices.Size(); i++)
				indexData[numIndices + i] = numVertices + thread.indices.Value(i);

			CopyBlockPositions(thread, numIndices / 3);

			numVertices += thread.vertices.Size();
			numIndices += thread.indices.Size();

			thread.vertices.Clear();
			thread.indices.Clear();
		}

		UpdateTangents(firstIndex);

		bounds.Reset();
		for (IntType i = 0; i < numIndices; i++)
		{
			const Vertex& vertex = vertexData[indexData[i]];
			bounds.AddPoint({ vertex.x, vertex.y, vertex.z });
		}

		Mesh<Vertex>::UpdateBuffers();
		completed = true;

		BuildBVH();
	}

	void VertexBuffer::ApplyTriangleRemovals()
	{
		if (triangleRemovals.isEmpty())
			return;

		// Keep complete triangles in their original order
		IntType keptIndices = 0;
		for (IntType i = 0; i < numIndices; i += 3)
		{
			const Vertex& v1 = vertexData[indexData[i]];
			const Vertex& v2 = vertexData[indexData[i + 1]];
			const Vertex& v3 = vertexData[indexData[i + 2]];
			BlockPos blockPos = GetTriangleBlockPos(i / 3);
			BoolType remove = false;

			// Bounds only reject distant candidates while deletion always requires an exact triangle match
			if (triangleRemovalBounds.ContainsPoint({ v1.x, v1.y, v1.z }))
			{
				auto found = triangleRemovals.find(TriangleHash(v1, v2, v3));
				if (found != triangleRemovals.end())
				{
					for (TriangleRemoval& match : found.value())
					{
						BoolType sameBlockPos = (!blockPos.IsValid() || !match.blockPos.IsValid() || match.blockPos == blockPos);
						if (sameBlockPos && match.count > 0 && SameTriangle(match.vertices, v1, v2, v3))
						{
							match.count--;
							remove = true;
							break;
						}
					}
				}
			}

			if (remove)
				continue;

			if (triangleBlockPos.Size())
				triangleBlockPos[keptIndices / 3] = triangleBlockPos.Value(i / 3);
			
			for (IntType v = 0; v < 3; v++)
				indexData[keptIndices++] = indexData[i + v];
		}

		triangleRemovals.clear();
		triangleRemovalBounds.Reset();

		if (keptIndices == numIndices)
			return;

		bounds.Reset();

		numIndices = keptIndices;
		if (triangleBlockPos.Size())
			triangleBlockPos.Alloc(numIndices / 3, false);

		if (!numIndices)
		{
			numVertices = 0;
			vertexData.FreeData();
			indexData.FreeData();
			return;
		}

		// Compact unused vertices and remap shared indices
		Heap<uint32_t> remap(numVertices);
		for (IntType i = 0; i < numIndices; i++)
			remap[indexData[i]] = 1;

		IntType keptVertices = 0;
		for (IntType i = 0; i < numVertices; i++)
		{
			if (!remap[i])
				continue;

			remap[i] = keptVertices;
			vertexData[keptVertices++] = vertexData[i];
		}

		for (IntType i = 0; i < numIndices; i++)
			indexData[i] = remap[indexData[i]];

		numVertices = keptVertices;
		vertexData.Alloc(numVertices, false);
		indexData.Alloc(numIndices, false);
	}

	void VertexBuffer::PrepareBlockPositions(IntType existingTriangles, IntType totalTriangles)
	{
		BlockPos oldOrigin = blockPosOrigin;
		if (!existingTriangles)
			blockPosOrigin = {};

		// Find a shared origin across all generation threads
		for (const ThreadData& thread : threads)
			blockPosOrigin.AddPos(thread.blockPosMin);

		if (!blockPosOrigin.IsValid())
		{
			triangleBlockPos.FreeData();
			return;
		}

		IntType oldSize = triangleBlockPos.Size();
		triangleBlockPos.Alloc(totalTriangles, false);

		// Repack existing triangles if the origin moved
		for (IntType i = 0; i < existingTriangles; i++)
		{
			if (i >= oldSize)
				triangleBlockPos[i] = BlockPos::NO_BLOCK_POS;
			else if (!(oldOrigin == blockPosOrigin))
				triangleBlockPos[i] = BlockPos(triangleBlockPos.Value(i), oldOrigin).Pack(blockPosOrigin);
		}
	}

	void VertexBuffer::CopyBlockPositions(ThreadData& thread, IntType triangleOffset)
	{
		if (!triangleBlockPos.Size())
			return;

		// Pack source positions into the combined vertex buffer's triangle range
		for (IntType i = 0; i < thread.indices.Size() / 3; i++)
		{
			uint32_t packed = BlockPos::NO_BLOCK_POS;
			if (i < thread.blockPositions.Size())
				packed = thread.blockPositions.Value(i).Pack(blockPosOrigin);

			triangleBlockPos[triangleOffset + i] = packed;
		}

		thread.blockPositions.Clear();
		thread.blockPosMin = {};
	}

	void VertexBuffer::ThreadData::Reserve(IntType addedVertices, IntType addedIndices)
	{
		// Double mesh capacity before appending a complete primitive
		if (vertices.Size() + addedVertices > vertices.heap.Size())
			vertices.heap.Alloc(std::max(vertices.Size() + addedVertices, std::max<IntType>(1024, vertices.heap.Size() * 2)), false);
		
		if (indices.Size() + addedIndices > indices.heap.Size())
			indices.heap.Alloc(std::max(indices.Size() + addedIndices, std::max<IntType>(1024, indices.heap.Size() * 2)), false);
	}

	void VertexBuffer::ThreadData::AddBlockPos(BlockPos pos, IntType addedTriangles)
	{
		if (!pos.IsValid() && !blockPositions.Size())
			return;

		blockPositions.Alloc(indices.heap.Size() / 3);

		// Align positions with triangles added without block metadata
		while (blockPositions.Size() < indices.Size() / 3 - addedTriangles)
			blockPositions.Append({});

		for (IntType i = 0; i < addedTriangles; i++)
			blockPositions.Append(pos);

		blockPosMin.AddPos(pos);
	}
}
