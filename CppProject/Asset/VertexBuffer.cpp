#include "VertexBuffer.hpp"
#include "AppHandler.hpp"
#include "Shader.hpp"
#include "Render/VertexBufferRenderer.hpp"

#include <QIODevice>
#include <QQuaternion>
#include <limits>

namespace CppProject
{
	VertexBuffer::VertexBuffer(QDataStream& stream, BoolType legacyBlockAxes, RealType legacyBlockWidth) : VertexBuffer()
	{
		valid = false;

		qint64 numMeshes = 0;
		stream >> numMeshes;
		QIODevice* device = stream.device();
		if (stream.status() != QDataStream::Ok || device == nullptr || numMeshes < 0 ||
			numMeshes > device->bytesAvailable() / (sizeof(qint64) * 2))
			return;

		for (IntType m = 0; m < numMeshes; m++)
		{
			qint64 numVert = 0, numInd = 0;
			stream >> numVert;
			stream >> numInd;

			// Validate mesh header
			if (stream.status() != QDataStream::Ok || numVert <= 0 || numInd <= 0 ||
				numVert > MAX_MESH_INDICES || numInd > MAX_MESH_INDICES || numInd % 3 != 0)
				return;

			qint64 vertexBytes = numVert * sizeof(Vertex);
			qint64 indexBytes = numInd * sizeof(uint32_t);
			if (vertexBytes > std::numeric_limits<int>::max() || indexBytes > std::numeric_limits<int>::max() ||
				vertexBytes + indexBytes > device->bytesAvailable())
				return;

			Mesh<>* mesh = new Mesh;
			mesh->numVertices = numVert;
			mesh->numIndices = numInd;

			// Read vertices
			mesh->vertexData.Alloc(mesh->numVertices);
			if (stream.readRawData((char*)mesh->vertexData.data, (int)vertexBytes) != vertexBytes)
			{
				WARNING("readRawData error");
				delete mesh;
				return;
			}

			// Read indices
			mesh->indexData.Alloc(mesh->numIndices);
			if (stream.readRawData((char*)mesh->indexData.data, (int)indexBytes) != indexBytes)
			{
				WARNING("readRawData error");
				delete mesh;
				return;
			}

			// Validate mesh indices
			for (IntType i = 0; i < mesh->numIndices; i++)
			{
				if (mesh->indexData[i] >= mesh->numVertices)
				{
					delete mesh;
					return;
				}
			}

			// Older scenery caches relied on a render-time block axis transform
			if (legacyBlockAxes)
			{
				auto rotateDirection = [](uint32_t packed)
				{
					return ((packed >> 8) & 255) | ((255 - (packed & 255)) << 8) | (packed & 0xFFFF0000);
				};
				for (IntType i = 0; i < mesh->numVertices; i++)
				{
					Vertex& vertex = mesh->vertexData[i];
					float oldX = vertex.x;
					vertex.x = vertex.y;
					vertex.y = legacyBlockWidth - oldX;
					vertex.normal = rotateDirection(vertex.normal);
					vertex.tangent = rotateDirection(vertex.tangent);
				}
			}

			// Create mesh buffers
			mesh->bounds = Bounds(mesh->vertexData);
			mesh->CreateBuffers(numIndices > MAX_BATCH_INDICES);

			meshes.append(mesh);

			numIndices += numInd;
		}

		valid = true;
	}

	IntType VertexBuffer::Submit(Shader* shader, Matrix boundsTransform)
	{
		if (!valid)
			return 0;

		IntType calls = 0;
		for (Mesh<>* mesh : meshes)
		{
			Bounds worldBounds;
			worldBounds.AddBounds(mesh->bounds, boundsTransform);

			if (GFX->IsVisible(worldBounds))
			{
				VB->occlusion.Begin(worldBounds, mesh->numIndices, !shader->HasVertexWind(mesh->hasWind));
				mesh->BeginUse();
				shader->SubmitVertices(Shader::TRIANGLE_LIST, mesh->numIndices);
				mesh->EndUse();
				VB->occlusion.End();

				calls++;
			}
			else
				shader->ResetObjects();
		}

		return calls;
	}

	void VertexBuffer::SetModelBend(const VecType& angles, const Matrix& rotation, const VecType& pivot,
		const VecType& axis, const VecType& range, const VecType& minimum,
		const VecType& maximum, const VecType& direction)
	{
		if (!valid || meshes.isEmpty() || range.z <= 0.0)
		{
			WARNING("Invalid model bend buffer or range");
			return;
		}

		if (!modelBend.enabled)
		{
			// Enclose every possible rotation around the bend pivot, including Z-fighting inflation
			for (Mesh<>* mesh : meshes)
			{
				RealType radius = 0.0;
				for (IntType corner = 0; corner < 8; corner++)
				{
					VecType point(
						corner & 1 ? mesh->bounds.maxPoint.x : mesh->bounds.minPoint.x,
						corner & 2 ? mesh->bounds.maxPoint.y : mesh->bounds.minPoint.y,
						corner & 4 ? mesh->bounds.maxPoint.z : mesh->bounds.minPoint.z);
					radius = std::max(radius, (rotation * point - pivot).GetLength() * 1.005);
				}
				VecType extent(radius, radius, radius);
				mesh->bounds = Bounds(pivot - extent, pivot + extent);
			}
		}

		modelBend.enabled = true;
		modelBend.angles = angles;
		modelBend.rotation = rotation;
		modelBend.pivot = pivot;
		modelBend.axis = axis;
		modelBend.range = range;
		modelBend.minimum = minimum;
		modelBend.maximum = maximum;
		modelBend.direction = direction;

		auto bendRotation = [&](RealType weight)
		{
			auto limit = [](RealType angle, RealType minimum, RealType maximum, RealType direction)
			{
				return angle == 0.0 ? 0.0 : std::min(std::max(angle, minimum), maximum) * direction;
			};
			// Quintic easing equals the weight at the midpoint and endpoint
			VecType angle(
				limit(angles.x * weight, minimum.x, maximum.x, direction.x),
				limit(angles.y * weight, minimum.y, maximum.y, direction.y),
				limit(angles.z * weight, minimum.z, maximum.z, direction.z));
			QQuaternion rotation = QQuaternion::fromAxisAndAngle(0, 0, 1, -angle.z) *
				QQuaternion::fromAxisAndAngle(1, 0, 0, -angle.x) *
				QQuaternion::fromAxisAndAngle(0, 1, 0, -angle.y);
			return VecType(rotation.x(), rotation.y(), rotation.z(), rotation.scalar());
		};
		modelBend.halfRotation = bendRotation(0.5);
		modelBend.fullRotation = bendRotation(1.0);
	}

	void VertexBuffer::SubmitModelBend(Shader* shader) const
	{
		IntType enabled = shader->GetUniformIndex("uModelBendEnabled");
		if (modelBend.enabled && enabled < 0)
			FATAL("Model bend vertex shader missing in " + shader->name);

		shader->SubmitFloat(enabled, modelBend.enabled ? 1.0f : 0.0f);
		if (!modelBend.enabled)
			return;

		shader->SubmitVec3(shader->GetUniformIndex("uModelBendAngles"), modelBend.angles);
		shader->SubmitMat4(shader->GetUniformIndex("uModelBendRotation"), modelBend.rotation);
		shader->SubmitVec4(shader->GetUniformIndex("uModelBendHalfRotation"),
			modelBend.halfRotation.x, modelBend.halfRotation.y, modelBend.halfRotation.z, modelBend.halfRotation.w);
		shader->SubmitVec4(shader->GetUniformIndex("uModelBendFullRotation"),
			modelBend.fullRotation.x, modelBend.fullRotation.y, modelBend.fullRotation.z, modelBend.fullRotation.w);
		shader->SubmitVec3(shader->GetUniformIndex("uModelBendPivot"), modelBend.pivot);
		shader->SubmitVec3(shader->GetUniformIndex("uModelBendAxis"), modelBend.axis);
		shader->SubmitVec4(shader->GetUniformIndex("uModelBendRange"),
			modelBend.range.x, modelBend.range.y, modelBend.range.z, modelBend.range.w);
		shader->SubmitVec3(shader->GetUniformIndex("uModelBendMinimum"), modelBend.minimum);
		shader->SubmitVec3(shader->GetUniformIndex("uModelBendMaximum"), modelBend.maximum);
		shader->SubmitVec3(shader->GetUniformIndex("uModelBendDirection"), modelBend.direction);
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

	void VertexBuffer::ThreadData::MeshData::Reserve(IntType addedVertices, IntType addedIndices)
	{
		// Double mesh capacity before appending a complete primitive
		if (vertices.Size() + addedVertices > vertices.heap.Size())
			vertices.Alloc(std::max(vertices.Size() + addedVertices, std::max<IntType>(1024, vertices.heap.Size() * 2)));
		if (indices.Size() + addedIndices > indices.heap.Size())
			indices.Alloc(std::max(indices.Size() + addedIndices, std::max<IntType>(1024, indices.heap.Size() * 2)));
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

		mesh->Reserve(1, 1);

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

		mesh->Reserve(3, 3);

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

		mesh->Reserve(4, 6);

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
			#pragma omp parallel for schedule(static)
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
		if (!valid)
		{
			stream << (qint64)0;
			return;
		}

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
		if (!valid)
			return sizeof(qint64);

		IntType bytes = 8; // 64 bits numMeshes
		for (Mesh<>* mesh : meshes)
			bytes +=
				8 + 8 + // 64 bits numVertices + 64 bit numIndices
				mesh->numVertices * sizeof(Vertex) +
				mesh->numIndices * sizeof(uint32_t);

		return bytes;
	}
}
