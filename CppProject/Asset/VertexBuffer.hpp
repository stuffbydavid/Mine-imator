#pragma once
#include "Asset.hpp"
#include "FastVector.hpp"
#include "Render/Mesh.hpp"

#include <QDataStream>

#define MAX_MESH_INDICES 10000000
#define MAX_BATCH_OBJECTS 1024
#define MAX_BATCH_TRIANGLES 20000
#define MAX_BATCH_INDICES MAX_BATCH_TRIANGLES * 3

namespace CppProject
{
	struct Shader;

	// Thread-safe vertex buffer asset, huge buffers are split up into several meshes upon creation.
	struct VertexBuffer : Asset
	{
		VertexBuffer() : Asset(ID_VertexBuffer) {}
		VertexBuffer(QDataStream& stream);
		~VertexBuffer();

		// Submit the vertex buffer to be rendered, returns the number of render calls made.
		IntType Submit(Shader* shader, Matrix boundsTransform);

		// Returns a new or existing vertex for editing an element with an index.
		Vertex& GetCurrentVertex(IntType elementIndex, IntType threadId = 0);

		// Adds a new complete vertex.
		void AddVertex(const Vertex& vertex, IntType threadId = 0);

		// Adds a triangle with 3 vertices and generates 3 indices.
		void AddTriangle(const Vertex& v1, const Vertex& v2, const Vertex& v3, IntType threadId = 0);

		// Adds a face with 4 vertices and generates 6 indices.
		void AddFace(const Vertex& v1, const Vertex& v2, const Vertex& v3, const Vertex& v4, IntType threadId = 0);

		// Allocates the meshes from the added vertices.
		void Complete();

		// Writes the vertex buffer data to the given stream.
		void Write(QDataStream& stream);

		// Returns the required size in bytes for writing to a stream.
		IntType GetWriteBytes() const;

		IntType numIndices = 0;
		QVector<Mesh<>*> meshes;
		BoolType saveData = false; // Whether to discard data on CPU-side if it can't be used for batches

		struct ThreadData
		{
			struct MeshData
			{
				FastVector<Vertex> vertices;
				FastVector<uint32_t> indices;
				Mesh<>* targetMesh = nullptr;
				IntType targetVertexOffset = 0, targetIndexOffset = 0;
			};
			QVector<MeshData*> meshes;
			Vertex currentVertex;
			BoolType elemAdded[5] = { false, false, false, false, false };
		} threads[OPENMP_MAX_THREADS];
	};
}