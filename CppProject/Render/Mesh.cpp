#include "Mesh.hpp"
#include "Vertex.hpp"
#include "World/World.hpp"

namespace CppProject
{
#if API_OPENGL
	template<typename V> QVector<QOpenGLBuffer*> Mesh<V>::deletedBuffers;
#endif

	template<typename V> Mesh<V>::~Mesh()
	{
		FreeBuffers();
	}

	template<typename V> void Mesh<V>::CreateBuffers(BoolType freeCpuData)
	{
		if (!numVertices || !numIndices)
			return;

	#if API_D3D11
		D3D11_BUFFER_DESC vBufferDesc = {};
		vBufferDesc.BindFlags = D3D11_BIND_VERTEX_BUFFER;
		vBufferDesc.CPUAccessFlags = 0;
		vBufferDesc.ByteWidth = vertexData.SizeInBytes();
		vBufferDesc.Usage = D3D11_USAGE_DEFAULT;

		D3D11_SUBRESOURCE_DATA vBufferData = { vertexData.Data(), 0, 0 };
		D3DCheckError(D3DDevice->CreateBuffer(&vBufferDesc, &vBufferData, &d3dVertexBuffer));

		D3D11_BUFFER_DESC iBufferDesc = {};
		iBufferDesc.BindFlags = D3D11_BIND_INDEX_BUFFER;
		iBufferDesc.CPUAccessFlags = 0;
		iBufferDesc.ByteWidth = indexData.SizeInBytes();
		iBufferDesc.Usage = D3D11_USAGE_DEFAULT;

		D3D11_SUBRESOURCE_DATA iBufferData = { indexData.Data(), 0, 0 };
		D3DCheckError(D3DDevice->CreateBuffer(&iBufferDesc, &iBufferData, &d3dIndexBuffer));
	#else
		glVertexBuffer = new QOpenGLBuffer(QOpenGLBuffer::VertexBuffer);
		glVertexBuffer->create();
		glVertexBuffer->bind();
		glVertexBuffer->allocate(vertexData.Data(), vertexData.SizeInBytes());
		glVertexBuffer->release();

		glIndexBuffer = new QOpenGLBuffer(QOpenGLBuffer::IndexBuffer);
		glIndexBuffer->create();
		glIndexBuffer->bind();
		glIndexBuffer->allocate(indexData.Data(), indexData.SizeInBytes());
		glIndexBuffer->release();
	#endif

		// Free copy of data on CPU
		if (freeCpuData)
		{
			vertexData.FreeData();
			indexData.FreeData();
		}
	}
	template<typename V> BoolType Mesh<V>::HasBuffers() const
	{
	#if API_D3D11
		return d3dVertexBuffer != nullptr;
	#else
		return glVertexBuffer != nullptr;
	#endif
	}

	template<typename V> void Mesh<V>::FreeBuffers(BoolType freeCpuData)
	{
	#if API_D3D11
		releaseAndReset(d3dVertexBuffer);
		releaseAndReset(d3dIndexBuffer);
	#else
		if (glVertexBuffer)
		{
			// Buffers can't be deleted mid-rendering on Mac OS, so it's done in CleanBuffers()
			deletedBuffers.append(glVertexBuffer);
			deletedBuffers.append(glIndexBuffer);
			glVertexBuffer = nullptr;
			glIndexBuffer = nullptr;
		}
	#endif

		// Free copy of data on CPU
		if (freeCpuData)
		{
			vertexData.FreeData();
			indexData.FreeData();
		}
	}

	template<typename V> void Mesh<V>::BeginUse()
	{
	#if API_D3D11
		UINT stride = sizeof(V);
		UINT offset = 0;
		D3DContext->IASetVertexBuffers(0, 1, &d3dVertexBuffer, &stride, &offset);
		D3DContext->IASetIndexBuffer(d3dIndexBuffer, DXGI_FORMAT_R32_UINT, 0);
	#else
		glVertexBuffer->bind();
		glIndexBuffer->bind();
	#endif
	}

	template<typename V> void Mesh<V>::EndUse()
	{
	#if API_OPENGL
		glVertexBuffer->release();
		glIndexBuffer->release();
	#endif
	}

	template<typename V> void Mesh<V>::CleanBuffers()
	{
	#if API_OPENGL
		for (QOpenGLBuffer* buff : deletedBuffers)
			delete buff;

		deletedBuffers.clear();
	#endif
	}

	template struct Mesh<Vertex>;
	template struct Mesh<WorldVertex>;
}