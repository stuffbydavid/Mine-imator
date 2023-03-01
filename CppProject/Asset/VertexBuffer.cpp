#include "VertexBuffer.hpp"
#include "Shader.hpp"

namespace CppProject
{
	VertexBuffer::VertexBuffer(QDataStream& stream) : VertexBuffer()
	{
		qint64 numMeshes;
		stream >> numMeshes;

		for (IntType m = 0; m < numMeshes; m++)
		{
			qint64 numVert, numInd;
			stream >> numVert;
			stream >> numInd;

			if (!numInd)
				break;

			Mesh<>* mesh = new Mesh;
			mesh->numVertices = numVert;
			mesh->numIndices = numInd;

			// Read vertices
			mesh->vertexData.Alloc(mesh->numVertices);
			if (stream.readRawData((char*)mesh->vertexData.data, (int)mesh->numVertices * sizeof(Vertex)) <= 0)
				WARNING("readRawData error");

			// Read indices
			mesh->indexData.Alloc(mesh->numIndices);
			if (stream.readRawData((char*)mesh->indexData.data, (int)mesh->numIndices * sizeof(uint32_t)) <= 0)
				WARNING("readRawData error");

			// Create mesh buffers
			mesh->bounds = Bounds(mesh->vertexData);
			mesh->CreateBuffers(numIndices > MAX_BATCH_INDICES);
			meshes.append(mesh);
			numIndices += numInd;
		}
	}

	IntType VertexBuffer::Submit(Shader* shader, Matrix boundsTransform)
	{
		IntType calls = 0;
		for (Mesh<>* mesh : meshes)
		{
			Bounds worldBounds;
			worldBounds.AddBounds(mesh->bounds, boundsTransform);

			if (GFX->IsVisible(worldBounds))
			{
				mesh->BeginUse();
				shader->SubmitVertices(Shader::TRIANGLE_LIST, mesh->numIndices);
				mesh->EndUse();
				calls++;
			}
			else
				shader->ResetObjects();
		}

		return calls;
	}

	VertexBuffer::~VertexBuffer()
	{
		for (Mesh<>* mesh : meshes)
			delete mesh;
	}

	Vertex& VertexBuffer::GetCurrentVertex(IntType elementIndex, IntType threadId)
	{
		ThreadData& thread = threads[threadId];

		// Begin new vertex
		if (thread.elemAdded[elementIndex])
		{
			for (IntType el = 0; el < 5; el++)
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

		// Find mesh
		ThreadData::MeshData* mesh;
		if (thread.meshes.size())
			mesh = thread.meshes.last();
		else
			thread.meshes.append(mesh = new ThreadData::MeshData);

		// Allocate data
		if (!mesh->indices.Size())
		{
			mesh->indices.Alloc(1024);
			mesh->vertices.Alloc(1024);
		}

		// Check if already added in current face
		IntType i = 0;
		for (IntType v = mesh->vertices.Size() - 1; v >= 0; v--)
		{
			if (i++ > 6)
				break;

			if (mesh->vertices.Value(v) == vertex)
			{
				mesh->indices.Append(v);
				return;
			}
		}

		mesh->indices.Append(mesh->vertices.Size());
		mesh->vertices.Append(vertex);
	}

	void VertexBuffer::AddTriangle(const Vertex& v1, const Vertex& v2, const Vertex& v3, IntType threadId)
	{
		ThreadData& thread = threads[threadId];

		// Find mesh
		ThreadData::MeshData* mesh;
		if (thread.meshes.size())
			mesh = thread.meshes.last();
		else
			thread.meshes.append(mesh = new ThreadData::MeshData);

		// Create new mesh
		if (mesh->indices.Size() + 3 > MAX_MESH_INDICES)
			thread.meshes.append(mesh = new ThreadData::MeshData);

		// Allocate data
		if (!mesh->indices.Size())
		{
			mesh->indices.Alloc(1024);
			mesh->vertices.Alloc(1024);
		}

		// Create triangle
		IntType vertOffset = mesh->vertices.Size();
		mesh->indices.Append(vertOffset + 0);
		mesh->indices.Append(vertOffset + 1);
		mesh->indices.Append(vertOffset + 2);
		mesh->vertices.Append(v1);
		mesh->vertices.Append(v2);
		mesh->vertices.Append(v3);
	}

	void VertexBuffer::AddFace(const Vertex& v1, const Vertex& v2, const Vertex& v3, const Vertex& v4, IntType threadId)
	{
		ThreadData& thread = threads[threadId];

		// Find mesh
		ThreadData::MeshData* mesh;
		if (thread.meshes.size())
			mesh = thread.meshes.last();
		else
			thread.meshes.append(mesh = new ThreadData::MeshData);

		// Create new mesh
		if (mesh->indices.Size() + 6 > MAX_MESH_INDICES)
			thread.meshes.append(mesh = new ThreadData::MeshData);

		// Allocate data
		if (!mesh->indices.Size())
		{
			mesh->indices.Alloc(1024);
			mesh->vertices.Alloc(1024);
		}

		// Create face
		IntType vertOffset = mesh->vertices.Size();
		mesh->indices.Append(vertOffset + 0);
		mesh->indices.Append(vertOffset + 1);
		mesh->indices.Append(vertOffset + 2);
		mesh->indices.Append(vertOffset + 2);
		mesh->indices.Append(vertOffset + 3);
		mesh->indices.Append(vertOffset + 0);
		mesh->vertices.Append(v1);
		mesh->vertices.Append(v2);
		mesh->vertices.Append(v3);
		mesh->vertices.Append(v4);
	}

	void VertexBuffer::Complete()
	{
		if (meshes.size())
		{
			WARNING("Buffer already completed");
			return;
		}

		// Find thread mesh targets
		IntType numThreads = 0;
		for (IntType t = 0; t < OPENMP_MAX_THREADS; t++)
		{
			ThreadData& thread = threads[t];

			// Complete current vertex
			for (IntType el = 0; el < 5; el++)
			{
				if (thread.elemAdded[el])
				{
					AddVertex(thread.currentVertex, t);
					break;
				}
			}

			// Thread has data
			if (thread.meshes.size())
				numThreads = t + 1;

			for (ThreadData::MeshData* threadMesh : thread.meshes)
			{
				// Find existing mesh with free space
				for (Mesh<>* mesh : meshes)
				{
					if (mesh->numIndices + threadMesh->indices.Size() >= MAX_MESH_INDICES)
						continue;

					threadMesh->targetMesh = mesh;
					threadMesh->targetVertexOffset = mesh->numVertices;
					threadMesh->targetIndexOffset = mesh->numIndices;
					mesh->numVertices += threadMesh->vertices.Size();
					mesh->numIndices += threadMesh->indices.Size();
					break;
				}

				// Create new
				if (!threadMesh->targetMesh)
				{
					Mesh<>* mesh = threadMesh->targetMesh = new Mesh;
					mesh->numVertices = threadMesh->vertices.Size();
					mesh->numIndices = threadMesh->indices.Size();
					meshes.append(mesh);
				}
			}
		}

		if (!meshes.size())
			return;

		// Allocate meshes
		for (Mesh<>* mesh : meshes)
		{
			mesh->vertexData.Alloc(mesh->numVertices);
			mesh->indexData.Alloc(mesh->numIndices);
			numIndices += mesh->numIndices;
		}

		auto processThread = [&](IntType t)
		{
			ThreadData& thread = threads[t];
			for (ThreadData::MeshData* threadMesh : thread.meshes)
			{
				Mesh<>* mesh = threadMesh->targetMesh;

				// Copy vertices
				memcpy(mesh->vertexData.data + threadMesh->targetVertexOffset,
					threadMesh->vertices.Data(),
					threadMesh->vertices.SizeInBytes());

				// Copy indices
				if (threadMesh->targetVertexOffset == 0)
					memcpy(mesh->indexData.data + threadMesh->targetIndexOffset,
						threadMesh->indices.Data(),
						threadMesh->indices.SizeInBytes());
				
				else
					for (IntType i = 0; i < threadMesh->indices.Size(); i++)
						mesh->indexData[threadMesh->targetIndexOffset + i] = threadMesh->indices.Value(i) + threadMesh->targetVertexOffset;

				// Explicitly free memory (also done on Heap<> destruction)
				threadMesh->vertices.Clear();
				threadMesh->indices.Clear();

				delete threadMesh;
			}
			thread.meshes.clear();
		};

		// Copy mesh data from thread(s)
		if (numThreads > 1)
		{
			#pragma OPENMP_FOR
			for (IntType t = 0; t < numThreads; t++)
				processThread(t);
		}
		else
			processThread(0);

		// Generate buffers for meshes
		for (Mesh<>* mesh : meshes)
		{
			// Calculate tangent vector for each triangle
			for (IntType i = 0; i < mesh->numIndices / 3; i++)
			{
				Vertex& v1 = mesh->vertexData[mesh->indexData.Value(i * 3)];
				Vertex& v2 = mesh->vertexData[mesh->indexData.Value(i * 3 + 1)];
				Vertex& v3 = mesh->vertexData[mesh->indexData.Value(i * 3 + 2)];
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

			mesh->bounds = Bounds(mesh->vertexData);
			mesh->CreateBuffers(numIndices > MAX_BATCH_INDICES && !saveData); // Release CPU data that can't be batched
		}
	}

	void VertexBuffer::Write(QDataStream& stream)
	{
		stream << (qint64)meshes.size();

		for (Mesh<>* mesh : meshes)
		{
			stream << (qint64)mesh->numVertices;
			stream << (qint64)mesh->numIndices;

			if (mesh->numIndices > 0)
			{
				stream.writeRawData((const char*)mesh->vertexData.Data(), (int)mesh->numVertices * sizeof(Vertex));
				stream.writeRawData((const char*)mesh->indexData.Data(), (int)mesh->numIndices * sizeof(uint32_t));

				if (numIndices > MAX_BATCH_INDICES) // Release CPU data of scenery that can't be batched
				{
					mesh->vertexData.FreeData();
					mesh->indexData.FreeData();
				}
			}
		}
	}

	IntType VertexBuffer::GetWriteBytes() const
	{
		IntType bytes = 8; // 64 bits numMeshes
		for (Mesh<>* mesh : meshes)
			bytes +=
				8 + 8 + // 64 bits numVertices + 64 bit numIndices
				mesh->numVertices * sizeof(Vertex) +
				mesh->numIndices * sizeof(uint32_t);

		return bytes;
	}
}