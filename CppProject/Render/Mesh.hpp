#pragma once
#include "Heap.hpp"
#include "Render/GraphicsApiHandler.hpp"
#include "Render/Vertex.hpp"
#include "Bounds.hpp"

namespace CppProject
{
	// Stores vertices and indices of a 3D mesh on the GPU and optionally CPU.
	template <typename V = Vertex> struct Mesh
	{
		~Mesh();

		// Create buffers from the stored vertex/index data, optionally releasing the data on the CPU side.
		void CreateBuffers(BoolType freeCpuData = true);

		// Returns whether the GPU buffers are loaded.
		BoolType HasBuffers() const;

		// Release buffers from GPU memory, optionally releasing the data on the CPU side.
		void FreeBuffers(BoolType freeCpuData = true);

		// Starts using the mesh for rendering triangles.
		void BeginUse();

		// Stops using the mesh for rendering triangles.
		void EndUse();

		// Delete the queued OpenGL buffers.
		static void CleanBuffers();

		IntType numVertices = 0;
		IntType numIndices = 0;
		Heap<V> vertexData;
		Heap<uint32_t> indexData;
		Bounds bounds;

	#if API_D3D11
		ID3D11Buffer* d3dVertexBuffer = nullptr;
		ID3D11Buffer* d3dIndexBuffer = nullptr;
	#else
		QOpenGLBuffer* glVertexBuffer = nullptr;
		QOpenGLBuffer* glIndexBuffer = nullptr;
		static QVector<QOpenGLBuffer*> deletedBuffers;
	#endif
	};
}