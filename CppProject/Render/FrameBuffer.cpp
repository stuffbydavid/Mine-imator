#include "FrameBuffer.hpp"
#include "Texture.hpp"

#include "AppHandler.hpp"
#include "AppWindow.hpp"
#include "Generated/GmlFunc.hpp"
#include "GraphicsApiHandler.hpp"

#include <QFloat16>

namespace CppProject
{
	FrameBuffer::FrameBuffer(IntType format, BoolType depthBuffer) :
		format(format),
		depthBuffer(depthBuffer)
	{
	#if OS_WINDOWS
		if (IS_D3D11)
		{
			switch (this->format)
			{
				case surface_rgba8unorm: d3dFormat = DXGI_FORMAT_R8G8B8A8_UNORM; break;
				case surface_r8unorm: d3dFormat = DXGI_FORMAT_R8_UNORM; break;
				case surface_rg8unorm: d3dFormat = DXGI_FORMAT_R8G8_UNORM; break;
				case surface_rgba4unorm: d3dFormat = DXGI_FORMAT_B4G4R4A4_UNORM; break;
				case surface_rgba16float: d3dFormat = DXGI_FORMAT_R16G16B16A16_FLOAT; break;
				case surface_r16float: d3dFormat = DXGI_FORMAT_R16_FLOAT; break;
				case surface_rgba32float: d3dFormat = DXGI_FORMAT_R32G32B32A32_FLOAT; break;
				case surface_r32float: d3dFormat = DXGI_FORMAT_R32_FLOAT; break;
				default:
					FATAL("Unknown surface format " + NumStr(this->format));
					break;
			}
		}
	#endif
		if (IS_OPENGL)
		{
			switch (this->format)
			{
				case surface_rgba8unorm:
					glInternalFormat = GL_RGBA8;
					glFormat = GL_RGBA;
					glType = GL_UNSIGNED_BYTE;
					break;
				case surface_r8unorm:
					glInternalFormat = GL_R8;
					glFormat = GL_RED;
					glType = GL_UNSIGNED_BYTE;
					break;
				case surface_rg8unorm:
					glInternalFormat = GL_RG8;
					glFormat = GL_RG;
					glType = GL_UNSIGNED_BYTE;
					break;
				case surface_rgba4unorm:
					glInternalFormat = GL_RGBA4;
					glFormat = GL_RGBA;
					glType = GL_UNSIGNED_SHORT_4_4_4_4;
					break;
				case surface_rgba16float:
					glInternalFormat = GL_RGBA16F;
					glFormat = GL_RGBA;
					glType = GL_HALF_FLOAT;
					break;
				case surface_r16float:
					glInternalFormat = GL_R16F;
					glFormat = GL_RED;
					glType = GL_HALF_FLOAT;
					break;
				case surface_rgba32float:
					glInternalFormat = GL_RGBA32F;
					glFormat = GL_RGBA;
					glType = GL_FLOAT;
					break;
				case surface_r32float:
					glInternalFormat = GL_R32F;
					glFormat = GL_RED;
					glType = GL_FLOAT;
					break;
				default:
					FATAL("Unknown surface format " + NumStr(this->format));
					break;
			}
		}
	}

	FrameBuffer::~FrameBuffer()
	{
	#if OS_WINDOWS
		if (IS_D3D11)
		{
			releaseAndReset(d3dColorTex);
			releaseAndReset(d3dDepthStencilTex);
			releaseAndReset(d3dDSV);
			releaseAndReset(d3dRTV);
			releaseAndReset(d3dSRV);
			Texture::d3dIdSRVMap.remove(d3dSRVId);
		}
	#endif
		if (IS_OPENGL)
		{
			if (glFboId)
				GFX->glDeleteFramebuffers(1, &glFboId);
			if (glColorTexId)
				GFX->glDeleteTextures(1, &glColorTexId);
			if (glDepthStencilRboId)
				GFX->glDeleteRenderbuffers(1, &glDepthStencilRboId);
			GL_CHECK_ERROR();
		}
	}

	IntType FrameBuffer::GetColorTexId() const
	{
	#if OS_WINDOWS
		if (IS_D3D11)
			return d3dSRVId;
	#endif
		if (IS_OPENGL)
			return glColorTexId;

		return 0;
	}

	void FrameBuffer::Update(QSize size)
	{
	#if OS_WINDOWS
		if (IS_D3D11)
		{
			if (size == this->size)
				return;
			this->size = size;

			// Free resources
			releaseAndReset(d3dColorTex);
			releaseAndReset(d3dDepthStencilTex);
			releaseAndReset(d3dDSV);
			releaseAndReset(d3dRTV);
			releaseAndReset(d3dSRV);

			// Create texture
			D3D11_TEXTURE2D_DESC texDesc = {};
			IntType maxSize = GFX->GetMaxSize();
			texDesc.Width = std::clamp(size.width(), 1, (int)maxSize);
			texDesc.Height = std::clamp(size.height(), 1, (int)maxSize);
			texDesc.MipLevels = 1;
			texDesc.ArraySize = 1;
			texDesc.Format = d3dFormat;
			texDesc.SampleDesc.Count = 1;
			texDesc.Usage = D3D11_USAGE_DEFAULT;
			texDesc.BindFlags = D3D11_BIND_RENDER_TARGET | D3D11_BIND_SHADER_RESOURCE;
			texDesc.CPUAccessFlags = 0;
			texDesc.MiscFlags = 0;
			D3DCheckError(D3DDevice->CreateTexture2D(&texDesc, nullptr, &d3dColorTex));
			if (!d3dColorTex)
				return;

			// Additional texture for depth/stencil
			if (depthBuffer)
			{
				D3D11_TEXTURE2D_DESC depthStencilDesc = {};
				depthStencilDesc.Width = texDesc.Width;
				depthStencilDesc.Height = texDesc.Height;
				depthStencilDesc.MipLevels = 1;
				depthStencilDesc.ArraySize = 1;
				depthStencilDesc.Format = DXGI_FORMAT_D24_UNORM_S8_UINT;
				depthStencilDesc.SampleDesc.Count = 1;
				depthStencilDesc.Usage = D3D11_USAGE_DEFAULT;
				depthStencilDesc.BindFlags = D3D11_BIND_DEPTH_STENCIL;
				depthStencilDesc.CPUAccessFlags = 0;
				depthStencilDesc.MiscFlags = 0;
				D3DCheckError(D3DDevice->CreateTexture2D(&depthStencilDesc, nullptr, &d3dDepthStencilTex));
				if (!d3dDepthStencilTex)
					return;

				// Create DSV
				D3D11_DEPTH_STENCIL_VIEW_DESC dsvDesc = {};
				dsvDesc.Format = depthStencilDesc.Format;
				dsvDesc.ViewDimension = D3D11_DSV_DIMENSION_TEXTURE2D;
				D3DCheckError(D3DDevice->CreateDepthStencilView(d3dDepthStencilTex, &dsvDesc, &d3dDSV));
			}

			// Create RTV
			D3D11_RENDER_TARGET_VIEW_DESC rtvDesc = {};
			rtvDesc.Format = texDesc.Format;
			rtvDesc.ViewDimension = D3D11_RTV_DIMENSION_TEXTURE2D;
			D3DCheckError(D3DDevice->CreateRenderTargetView(d3dColorTex, &rtvDesc, &d3dRTV));

			// Create SRV
			D3D11_SHADER_RESOURCE_VIEW_DESC srvDesc = {};
			srvDesc.Format = texDesc.Format;
			srvDesc.ViewDimension = D3D11_SRV_DIMENSION_TEXTURE2D;
			srvDesc.Texture2D.MostDetailedMip = 0;
			srvDesc.Texture2D.MipLevels = 1;
			D3DCheckError(D3DDevice->CreateShaderResourceView(d3dColorTex, &srvDesc, &d3dSRV));
			if (!d3dSRVId)
				d3dSRVId = Texture::d3dSRVNextId++;
			Texture::d3dIdSRVMap[d3dSRVId] = d3dSRV;
		}
	#endif
		if (IS_OPENGL)
		{
			// Switch FBO to this context
			if (fboContext && fboContext != GFX->glContext)
			{
				GFX->glDeleteFramebuffers(1, &glFboId);
				glFboId = 0;
				fboContext = GFX->glContext;
				this->size = QSize();
			}

			// Create FBOs
			if (!glFboId)
			{
				GFX->glGenFramebuffers(1, &glFboId);
				fboContext = GFX->glContext;
			}

			// Create texture
			if (!glColorTexId)
				GFX->glGenTextures(1, &glColorTexId);

			// Create Renderbuffer object
			if (!glDepthStencilRboId && depthBuffer)
				GFX->glGenRenderbuffers(1, &glDepthStencilRboId);

			GL_CHECK_ERROR();

			if (size == this->size)
				return;
			this->size = size;

			// Resize color and depth/stencil texture
			GFX->glBindTexture(GL_TEXTURE_2D, glColorTexId);
			GFX->glTexImage2D(GL_TEXTURE_2D, 0, glInternalFormat, size.width(), size.height(), 0, glFormat, glType, 0);
			GFX->glBindTexture(GL_TEXTURE_2D, 0);
			if (depthBuffer)
			{
				GFX->glBindRenderbuffer(GL_RENDERBUFFER, glDepthStencilRboId);
				GFX->glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8, size.width(), size.height());
				GFX->glBindRenderbuffer(GL_RENDERBUFFER, 0);
			}
			GL_CHECK_ERROR();

			// Bind to FBOs
			GLint prevFboId;
			GFX->glGetIntegerv(GL_DRAW_FRAMEBUFFER_BINDING, &prevFboId);
			GFX->glBindFramebuffer(GL_FRAMEBUFFER, glFboId);
			GFX->glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, glColorTexId, 0);
			if (depthBuffer)
				GFX->glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_RENDERBUFFER, glDepthStencilRboId);
			GL_CHECK_ERROR();

		#if DEBUG_MODE
			GLenum status = GFX->glCheckFramebufferStatus(GL_FRAMEBUFFER);
			GL_CHECK_ERROR();
			if (status != GL_FRAMEBUFFER_COMPLETE)
				WARNING("Incomplete framebuffer");
		#endif
			GFX->glBindFramebuffer(GL_FRAMEBUFFER, prevFboId);
			GL_CHECK_ERROR();
		}
	}

	BoolType FrameBuffer::BeginUse()
	{
	#if OS_WINDOWS
		if (IS_D3D11)
		{
			D3DContext->OMSetRenderTargets(1, &d3dRTV, d3dDSV);
			D3D11_VIEWPORT viewport = { 0, 0, (float)size.width(), (float)size.height(), 0.0, 1.0 };
			D3DContext->RSSetViewports(1, &viewport);
			return true;
		}
	#endif
		if (IS_OPENGL)
		{
			GFX->glBindFramebuffer(GL_FRAMEBUFFER, glFboId);
			GL_CHECK_ERROR();
		#if DEBUG_MODE && 1
			GLenum status = GFX->glCheckFramebufferStatus(GL_FRAMEBUFFER);
			GL_CHECK_ERROR();
			if (status != GL_FRAMEBUFFER_COMPLETE)
			{
				WARNING("Invalid framebuffer status " + NumStr(status));
				return false;
			}
		#endif

			GFX->glViewport(0, 0, size.width(), size.height());
			GL_CHECK_ERROR();

			GLenum buffers = GL_COLOR_ATTACHMENT0;
			GFX->glDrawBuffers(1, &buffers);
			GL_CHECK_ERROR();
			return true;
		}
		return false;
	}

	void FrameBuffer::EndUse()
	{
	#if OS_WINDOWS
		if (IS_D3D11)
		{
			ID3D11RenderTargetView* nullViews[] = { nullptr };
			D3DContext->OMSetRenderTargets(1, nullViews, 0);
		}
	#endif
		if (IS_OPENGL)
		{
			GFX->glBindFramebuffer(GL_FRAMEBUFFER, 0);
			GL_CHECK_ERROR();
		}
	}

	void FrameBuffer::CopyData(BoolType color, uchar* dst)
	{
		if (!color && !depthBuffer)
		{
			WARNING("No depth buffer created");
			return;
		}

		if (!size.width() || !size.height())
			return;

	#if OS_WINDOWS
		if (IS_D3D11)
		{
			// Create copy of texture for reading
			ID3D11Texture2D* stagingTex;
			ID3D11Texture2D* tex = color ? d3dColorTex : d3dDepthStencilTex;
			D3D11_TEXTURE2D_DESC texDesc = {};
			tex->GetDesc(&texDesc);
			texDesc.Usage = D3D11_USAGE_STAGING;
			texDesc.BindFlags = 0;
			texDesc.CPUAccessFlags = D3D11_CPU_ACCESS_READ;
			D3DCheckError(D3DDevice->CreateTexture2D(&texDesc, nullptr, &stagingTex));
			if (!stagingTex)
				return;

			D3DContext->CopyResource(stagingTex, tex);

			D3D11_MAPPED_SUBRESOURCE texRes = {};
			IntType rowSize = texDesc.Width * GetPixelSize(color);
			D3DContext->Map(stagingTex, 0, D3D11_MAP_READ, 0, &texRes);

			// Size differs, clear destination
			if (size.width() != texDesc.Width || size.height() != texDesc.Height)
				memset(dst, 0, rowSize * size.height());

			// Copy rows
			for (IntType y = 0; y < texDesc.Height; y++)
				memcpy(dst + y * rowSize,
					(uchar*)texRes.pData + y * texRes.RowPitch,
					rowSize);
			D3DContext->Unmap(stagingTex, 0);
			stagingTex->Release();
		}
	#endif
		if (IS_OPENGL)
		{
			IntType rowSize = size.width() * GetPixelSize(color);
			uchar* dataFlipped = new uchar[rowSize * size.height()];

			GLint prevFboId;
			GLint prevPackAlignment;
			GFX->glGetIntegerv(GL_DRAW_FRAMEBUFFER_BINDING, &prevFboId);
			GFX->glGetIntegerv(GL_PACK_ALIGNMENT, &prevPackAlignment);
			GFX->glPixelStorei(GL_PACK_ALIGNMENT, 1);
			GFX->glBindFramebuffer(GL_FRAMEBUFFER, glFboId);
			if (color)
				GFX->glReadPixels(0, 0, size.width(), size.height(), glFormat, glType, dataFlipped);
			else
			{
				GFX->glBindRenderbuffer(GL_RENDERBUFFER, glDepthStencilRboId);
				GFX->glReadPixels(0, 0, size.width(), size.height(), GL_DEPTH_STENCIL, GL_UNSIGNED_INT_24_8, dataFlipped);
				GFX->glBindRenderbuffer(GL_RENDERBUFFER, 0);
			}
			GFX->glBindFramebuffer(GL_FRAMEBUFFER, prevFboId);
			GFX->glPixelStorei(GL_PACK_ALIGNMENT, prevPackAlignment);
			GL_CHECK_ERROR();

			// Copy in correct row order
			for (IntType y = 0; y < size.height(); y++)
				memcpy(dst + rowSize * y,
					dataFlipped + rowSize * (size.height() - 1 - y),
					rowSize);

			delete[] dataFlipped;
		}
	}

	void FrameBuffer::CopyColorData(uchar* dst)
	{
		IntType pixelCount = size.width() * size.height();
		memset(dst, 0, pixelCount * 4);
		if (!pixelCount)
			return;

		if (format == surface_rgba8unorm)
		{
			CopyData(true, dst);
			return;
		}

		IntType pixelSize = GetPixelSize(true);
		uchar* data = new uchar[pixelCount * pixelSize]();
		CopyData(true, data);

		auto setPixel = [dst](IntType index, uchar red, uchar green, uchar blue, uchar alpha)
		{
			dst[index * 4] = red;
			dst[index * 4 + 1] = green;
			dst[index * 4 + 2] = blue;
			dst[index * 4 + 3] = alpha;
		};
		switch (format)
		{
			case surface_r8unorm:
				for (IntType i = 0; i < pixelCount; i++)
					setPixel(i, data[i], 0, 0, 255);
				break;

			case surface_rg8unorm:
				for (IntType i = 0; i < pixelCount; i++)
					setPixel(i, data[i * pixelSize], data[i * pixelSize + 1], 0, 255);
				break;

			case surface_rgba4unorm:
				for (IntType i = 0; i < pixelCount; i++)
				{
					uint16_t packed;
					memcpy(&packed, data + i * pixelSize, sizeof(packed));
					if (IS_D3D11)
						setPixel(i,
							((packed >> 8) & 0xf) * 17,
							((packed >> 4) & 0xf) * 17,
							(packed & 0xf) * 17,
							((packed >> 12) & 0xf) * 17
						);
					if (IS_OPENGL)
						setPixel(i,
							((packed >> 12) & 0xf) * 17,
							((packed >> 8) & 0xf) * 17,
							((packed >> 4) & 0xf) * 17,
							(packed & 0xf) * 17
						);
				}
				break;

			case surface_rgba16float:
				for (IntType i = 0; i < pixelCount; i++)
				for (IntType c = 0; c < 4; c++)
				{
					qfloat16 value;
					memcpy(&value, data + i * pixelSize + c * sizeof(value), sizeof(value));
					dst[i * 4 + c] = std::clamp((float)value, 0.f, 1.f) * 255;
				}
				break;

			case surface_r16float:
				for (IntType i = 0; i < pixelCount; i++)
				{
					qfloat16 value;
					memcpy(&value, data + i * pixelSize, sizeof(value));
					setPixel(i, std::clamp((float)value, 0.f, 1.f) * 255, 0, 0, 255);
				}
				break;

			case surface_rgba32float:
				for (IntType i = 0; i < pixelCount; i++)
				for (IntType c = 0; c < 4; c++)
				{
					float value;
					memcpy(&value, data + i * pixelSize + c * sizeof(value), sizeof(value));
					dst[i * 4 + c] = std::clamp(value, 0.f, 1.f) * 255;
				}
				break;

			case surface_r32float:
				for (IntType i = 0; i < pixelCount; i++)
				{
					float value;
					memcpy(&value, data + i * pixelSize, sizeof(value));
					setPixel(i, std::clamp(value, 0.f, 1.f) * 255, 0, 0, 255);
				}
				break;
		}

		delete[] data;
	}


	IntType FrameBuffer::GetPixelSize(BoolType color) const
	{
		if (!color) // Depth/stencil data
			return sizeof(uint32_t);

		const IntType byteSize = sizeof(uint8_t);
		const IntType floatSize = sizeof(float);
		const IntType halfSize = floatSize / 2;
		switch (format)
		{
			case surface_rgba8unorm:	return 4 * byteSize;
			case surface_r8unorm:		return 1 * byteSize;
			case surface_rg8unorm:		return 2 * byteSize;
			case surface_rgba4unorm:	return 2 * byteSize;
			case surface_rgba16float:	return 4 * halfSize;
			case surface_r16float:		return 1 * halfSize;
			case surface_rgba32float:	return 4 * floatSize;
			case surface_r32float:		return 1 * floatSize;
		}

		return 0;
	}
}
