#include "Mesh.hpp"
#include "AppHandler.hpp"
#include "Vertex.hpp"
#include "World/World.hpp"

namespace CppProject
{
	template<typename V> QVector<QOpenGLBuffer*> Mesh<V>::deletedBuffers;

	template<typename V> Mesh<V>::~Mesh()
	{
		FreeBuffers();
	}

	template<typename V> void Mesh<V>::CreateBuffers(BoolType freeCpuData)
	{
		if (!numVertices || !numIndices)
			return;

#if OS_WINDOWS
		if (IS_D3D11)
		{
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
		}
#endif
		if (IS_OPENGL)
		{
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
		}

		// Free copy of data on CPU
		if (freeCpuData)
		{
			vertexData.FreeData();
			indexData.FreeData();
		}
	}

	template<typename V> void Mesh<V>::UpdateBuffers()
	{
		if (!numVertices || !numIndices)
		{
			FreeBuffers(false);
			return;
		}

		if (!HasBuffers())
		{
			CreateBuffers(false);
			return;
		}

#if OS_WINDOWS
		if (IS_D3D11)
		{
			D3D11_BUFFER_DESC vertexDesc, indexDesc;
			d3dVertexBuffer->GetDesc(&vertexDesc);
			d3dIndexBuffer->GetDesc(&indexDesc);

			// Reallocate when editing changes the buffer sizes
			if (vertexDesc.ByteWidth != vertexData.SizeInBytes() || indexDesc.ByteWidth != indexData.SizeInBytes())
			{
				FreeBuffers(false);
				CreateBuffers(false);
				return;
			}

			D3DContext->UpdateSubresource(d3dVertexBuffer, 0, nullptr, vertexData.Data(), 0, 0);
			D3DContext->UpdateSubresource(d3dIndexBuffer, 0, nullptr, indexData.Data(), 0, 0);
		}
#endif
		if (IS_OPENGL)
		{
			glVertexBuffer->bind();
			if (glVertexBuffer->size() != vertexData.SizeInBytes())
				glVertexBuffer->allocate(vertexData.Data(), vertexData.SizeInBytes());
			else
				glVertexBuffer->write(0, vertexData.Data(), vertexData.SizeInBytes());
			glVertexBuffer->release();

			glIndexBuffer->bind();
			if (glIndexBuffer->size() != indexData.SizeInBytes())
				glIndexBuffer->allocate(indexData.Data(), indexData.SizeInBytes());
			else
				glIndexBuffer->write(0, indexData.Data(), indexData.SizeInBytes());
			glIndexBuffer->release();
		}
	}

	template<typename V> BoolType Mesh<V>::HasBuffers() const
	{
#if OS_WINDOWS
		if (IS_D3D11)
			return d3dVertexBuffer != nullptr;
#endif
		if (IS_OPENGL)
			return glVertexBuffer != nullptr;

		return false;
	}

	template<typename V> void Mesh<V>::FreeBuffers(BoolType freeCpuData)
	{
#if OS_WINDOWS
		if (IS_D3D11)
		{
			releaseAndReset(d3dVertexBuffer);
			releaseAndReset(d3dIndexBuffer);
		}
#endif
		if (IS_OPENGL)
		{
			if (glVertexBuffer)
			{
				// Buffers can't be deleted mid-rendering on Mac OS, so it's done in CleanBuffers()
				deletedBuffers.append(glVertexBuffer);
				deletedBuffers.append(glIndexBuffer);
				glVertexBuffer = nullptr;
				glIndexBuffer = nullptr;
			}

			// Free copy of data on CPU
			if (freeCpuData)
			{
				vertexData.FreeData();
				indexData.FreeData();
			}
		}
	}

	template<typename V> void Mesh<V>::BeginUse()
	{
#if OS_WINDOWS
		if (IS_D3D11)
		{
			UINT stride = sizeof(V), offset = 0;
			D3DContext->IASetVertexBuffers(0, 1, &d3dVertexBuffer, &stride, &offset);
			D3DContext->IASetIndexBuffer(d3dIndexBuffer, DXGI_FORMAT_R32_UINT, 0);
			return;
		}
#endif
		if (IS_OPENGL)
		{
			glVertexBuffer->bind();
			glIndexBuffer->bind();
		}
	}

	template<typename V> void Mesh<V>::EndUse()
	{
		if (IS_OPENGL)
		{
			glVertexBuffer->release();
			glIndexBuffer->release();
		}
	}

	template<typename V> void Mesh<V>::CleanBuffers()
	{
		if (IS_OPENGL)
		{
			for (QOpenGLBuffer* buff : deletedBuffers)
				delete buff;

			deletedBuffers.clear();
		}
	}

	template struct Mesh<Vertex>;
	template struct Mesh<WorldVertex>;
}
