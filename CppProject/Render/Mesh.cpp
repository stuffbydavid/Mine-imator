#include "Mesh.hpp"
#include "AppHandler.hpp"
#include "Vertex.hpp"
#include "Asset/Shader.hpp"
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

		// Keep the full CPU records for batch construction, compact only the uploaded stream
		Heap<CompactBendVertex> compactData;
		compactBendData = bendData.Size() != 0;
		if (compactBendData)
		{
			compactData.Alloc(bendData.Size(), false);
			for (IntType i = 0; i < bendData.Size(); i++)
				if (!bendData.Value(i).Compact(compactData[i]))
				{
					compactBendData = false;
					break;
				}
		}
		const void* bendBytes = compactBendData ? (const void*)compactData.Data() : (const void*)bendData.Data();
		IntType bendSize = compactBendData ? compactData.SizeInBytes() : bendData.SizeInBytes();

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

			if (bendData.Size())
			{
				vBufferDesc.ByteWidth = bendSize;
				vBufferData.pSysMem = bendBytes;
				D3DCheckError(D3DDevice->CreateBuffer(&vBufferDesc, &vBufferData, &d3dBendBuffer));
			}

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

			if (bendData.Size())
			{
				glBendBuffer = new QOpenGLBuffer(QOpenGLBuffer::VertexBuffer);
				glBendBuffer->create();
				glBendBuffer->bind();
				glBendBuffer->allocate(bendBytes, bendSize);
				glBendBuffer->release();
			}

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
			bendData.FreeData();
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
		compactBendData = false;
		if (freeCpuData)
			bendData.FreeData();
#if OS_WINDOWS
		if (IS_D3D11)
		{
			releaseAndReset(d3dVertexBuffer);
			releaseAndReset(d3dIndexBuffer);
			releaseAndReset(d3dBendBuffer);
		}
#endif
		if (IS_OPENGL)
		{
			if (glVertexBuffer)
			{
				// Buffers can't be deleted mid-rendering on Mac OS, so it's done in CleanBuffers()
				deletedBuffers.append(glVertexBuffer);
				deletedBuffers.append(glIndexBuffer);
				if (glBendBuffer)
					deletedBuffers.append(glBendBuffer);
				glBendBuffer = nullptr;
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
			GFX->shader->compactBendInput = compactBendData;
			UINT bendStride = compactBendData ? sizeof(CompactBendVertex) : sizeof(BendVertex);
			D3DContext->IASetVertexBuffers(1, 1, &d3dBendBuffer, &bendStride, &offset);
			D3DContext->IASetIndexBuffer(d3dIndexBuffer, DXGI_FORMAT_R32_UINT, 0);
			return;
		}
#endif
		if (IS_OPENGL)
		{
			glVertexBuffer->bind();
			glIndexBuffer->bind();
			if (GFX->shader->vertexFormat == Shader::VERTEX_BUFFER)
			{
				if (glBendBuffer)
					glBendBuffer->bind();
				for (int i = 0; i < 4; i++)
				{
					IntType location = GFX->shader->attributeLocation[6 + i];
					if (location < 0)
						continue;
					if (glBendBuffer)
					{
						GFX->glEnableVertexAttribArray(location);
						IntType components = compactBendData && i == 3 ? 2 : 4;
						IntType stride = compactBendData ? sizeof(CompactBendVertex) : sizeof(BendVertex);
						GFX->glVertexAttribPointer(location, components, GL_FLOAT, false, stride, (void*)(size_t)(i * 4 * sizeof(float)));
					}
					else
					{
						GFX->glDisableVertexAttribArray(location);
						GFX->shader->program->setAttributeValue(location, 0.f, 0.f, 0.f, 0.f);
					}
				}
				glVertexBuffer->bind();
			}
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
