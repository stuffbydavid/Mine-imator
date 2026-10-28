#pragma once
#include "Asset.hpp"
#include "FastVector.hpp"
#include "Render/Mesh.hpp"

// Suppress tinybvh's MSVC notices
#if defined(_MSC_VER) && !defined(__clang__)
#pragma push_macro("_Pragma")
#undef _Pragma
#define _Pragma(...)
#endif

#pragma push_macro("WARNING")
#undef WARNING
#include "tinybvh/tiny_bvh.h"
#pragma pop_macro("WARNING")

#if defined(_MSC_VER) && !defined(__clang__)
#pragma pop_macro("_Pragma")
#endif

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

		// Queue a matching triangle for removal.
		void RemoveTriangle(const Vertex& v1, const Vertex& v2, const Vertex& v3);

		// Adds a face with 4 vertices and generates 6 indices.
		void AddFace(const Vertex& v1, const Vertex& v2, const Vertex& v3, const Vertex& v4, IntType threadId = 0);

		// Allocates the mesh from the added vertices, optionally updating tangents.
		void Complete(BoolType updateTangents = true);

		// Updates tangents for triangles starting at the given index.
		void UpdateTangents(IntType firstIndex = 0);

		// Builds a raycasting acceleration BVH using the geometry.
		void BuildBVH();

		// Writes the vertex buffer data to the given stream.
		void Write(QDataStream& stream);

		// Returns the required size in bytes for writing to a stream.
		IntType GetWriteBytes() const;

		// Creates a copy of the vertex buffer data without allocating GPU buffers.
		VertexBuffer* Copy() const;

		// Uploads edited geometry and rebuilds bounds, cached batches and the raycasting BVH.
		void UpdateBuffers();

		BoolType batching = true; // Allow batching of the vertex buffer
		bool valid = true;
		bool completed = false;
		tinybvh::BVH bvh;

	private:
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

		struct TriangleRemoval
		{
			Vertex vertices[3];
			IntType count = 1;
		};

		// Removes queued triangles in one scan and compacts the retained geometry.
		void ApplyTriangleRemovals();

		QHash<quint64, QVector<TriangleRemoval>> triangleRemovals;
		Bounds triangleRemovalBounds;
	};
}
