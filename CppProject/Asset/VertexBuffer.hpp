#pragma once
#include "Asset.hpp"
#include "FastVector.hpp"
#include "Render/Mesh.hpp"

#include <QDataStream>

namespace CppProject
{
	struct Shader;

	// Vertex buffer asset with per-thread generation data and retained CPU geometry
	struct VertexBuffer : Asset, Mesh<Vertex>
	{
		VertexBuffer() : Asset(ID_VertexBuffer) {}
		VertexBuffer(QDataStream& stream, BoolType batching = true);
		VertexBuffer(const VertexBuffer&) = delete;
		VertexBuffer& operator=(const VertexBuffer&) = delete;
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

		// Allocates the mesh from the added vertices, optionally updating tangents.
		void Complete(BoolType updateTangents = true);

		// Writes the vertex buffer data to the given stream.
		void Write(QDataStream& stream);

		// Returns the required size in bytes for writing to a stream.
		IntType GetWriteBytes() const;

		BoolType batching = true; // Allow batching of the vertex buffer
		bool valid = true;
		bool completed = false;

		struct ThreadData
		{
			// Increase capacity before appending a complete primitive.
			void Reserve(IntType addedVertices, IntType addedIndices);

			FastVector<Vertex> vertices;
			FastVector<uint32_t> indices;
			IntType targetVertexOffset = 0, targetIndexOffset = 0;
			Vertex currentVertex;
			BoolType elemAdded[4] = { false, false, false, false };
		} threads[OPENMP_MAX_THREADS];
	};
}
