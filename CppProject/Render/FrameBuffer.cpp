#include "FrameBuffer.hpp"
#include "Texture.hpp"

#include "AppWindow.hpp"
#include "GraphicsApiHandler.hpp"

namespace CppProject
{
#if API_D3D11
	FrameBuffer::~FrameBuffer()
	{
		releaseAndReset(d3dColorTex);
		releaseAndReset(d3dDepthStencilTex);
		releaseAndReset(d3dDSV);
		releaseAndReset(d3dRTV);
		releaseAndReset(d3dSRV);
		Texture::d3dIdSRVMap.remove(d3dSRVId);
	}

	IntType FrameBuffer::GetColorTexId() const
	{
		return d3dSRVId;
	}

	void FrameBuffer::Update(QSize size)
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
		texDesc.Format = hdr ? DXGI_FORMAT_R32G32B32A32_FLOAT : DXGI_FORMAT_R8G8B8A8_UNORM;
		texDesc.SampleDesc.Count = 1;
		texDesc.Usage = D3D11_USAGE_DEFAULT;
		texDesc.BindFlags = D3D11_BIND_RENDER_TARGET | D3D11_BIND_SHADER_RESOURCE;
		texDesc.CPUAccessFlags = 0;
		texDesc.MiscFlags = 0;
		D3DCheckError(D3DDevice->CreateTexture2D(&texDesc, nullptr, &d3dColorTex));

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

	BoolType FrameBuffer::BeginUse()
	{
		D3DContext->OMSetRenderTargets(1, &d3dRTV, d3dDSV);
		D3D11_VIEWPORT viewport = { 0, 0, (float)size.width(), (float)size.height(), 0.0, 1.0 };
		D3DContext->RSSetViewports(1, &viewport);
		return true;
	}

	void FrameBuffer::EndUse()
	{
		ID3D11RenderTargetView* nullViews[] = { nullptr };
		D3DContext->OMSetRenderTargets(1, nullViews, 0);
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

		// Create copy of texture for reading
		ID3D11Texture2D* stagingTex;
		ID3D11Texture2D* tex = color ? d3dColorTex : d3dDepthStencilTex;
		D3D11_TEXTURE2D_DESC texDesc = {};
		tex->GetDesc(&texDesc);
		texDesc.Usage = D3D11_USAGE_STAGING;
		texDesc.BindFlags = 0;
		texDesc.CPUAccessFlags = D3D11_CPU_ACCESS_READ;
		D3DCheckError(D3DDevice->CreateTexture2D(&texDesc, nullptr, &stagingTex));
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
#else
	FrameBuffer::~FrameBuffer()
	{
		if (glFboId)
			GFX->glDeleteFramebuffers(1, &glFboId);
		if (glColorTexId)
			GFX->glDeleteTextures(1, &glColorTexId);
		if (glDepthStencilRboId)
			GFX->glDeleteRenderbuffers(1, &glDepthStencilRboId);
		GL_CHECK_ERROR();
	}

	IntType FrameBuffer::GetColorTexId() const
	{
		return glColorTexId;
	}

	void FrameBuffer::Update(QSize size)
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
		GFX->glTexImage2D(GL_TEXTURE_2D, 0, hdr ? GL_RGBA32F : GL_RGBA, size.width(), size.height(), 0, GL_RGBA, hdr ? GL_FLOAT : GL_UNSIGNED_BYTE, 0);
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

	#if DEBUG_MODE && 1
		GLenum status = GFX->glCheckFramebufferStatus(GL_FRAMEBUFFER);
		GL_CHECK_ERROR();
		if (status != GL_FRAMEBUFFER_COMPLETE)
			WARNING("Incomplete framebuffer");
	#endif
		GFX->glBindFramebuffer(GL_FRAMEBUFFER, prevFboId);
		GL_CHECK_ERROR();
	}

	BoolType FrameBuffer::BeginUse()
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

	void FrameBuffer::EndUse()
	{
		GFX->glBindFramebuffer(GL_FRAMEBUFFER, 0);
		GL_CHECK_ERROR();
	}

	void FrameBuffer::CopyData(BoolType color, uchar* dst)
	{
		if (!color && !depthBuffer)
		{
			WARNING("No depth buffer created");
			return;
		}
		IntType rowSize =size.width() * GetPixelSize(color);
		uchar* dataFlipped = new uchar[rowSize * size.height()];

		GLint prevFboId;
		GFX->glGetIntegerv(GL_DRAW_FRAMEBUFFER_BINDING, &prevFboId);
		GFX->glBindFramebuffer(GL_FRAMEBUFFER, glFboId);
		if (color)
			GFX->glReadPixels(0, 0, size.width(), size.height(), GL_RGBA, hdr ? GL_FLOAT : GL_UNSIGNED_BYTE, dataFlipped);
		else
		{
			GFX->glBindRenderbuffer(GL_RENDERBUFFER, glDepthStencilRboId);
			GFX->glReadPixels(0, 0, size.width(), size.height(), GL_DEPTH_STENCIL, GL_UNSIGNED_INT_24_8, dataFlipped);
			GFX->glBindRenderbuffer(GL_RENDERBUFFER, 0);
		}
		GFX->glBindFramebuffer(GL_FRAMEBUFFER, prevFboId);
		GL_CHECK_ERROR();

		// Copy in correct row order
		for (IntType y = 0; y < size.height(); y++)
			memcpy(dst + rowSize * y,
				   dataFlipped + rowSize * (size.height() - 1 - y),
				   rowSize);

		delete[] dataFlipped;
	}
#endif

	void FrameBuffer::CopyColorData(uchar* dst)
	{
		if (!hdr)
		{
			CopyData(true, dst);
			return;
		}

		// Convert from HDR
		float* data = new float[size.width() * size.height() * 4];
		CopyData(true, (uchar*)data);
		for (IntType y = 0; y < size.height(); y++)
		for (IntType x = 0; x < size.width(); x++)
			for (IntType i = 0; i < 4; i++)
				dst[(y * size.width() + x) * 4 + i] = std::clamp(data[(y * size.width() + x) * 4 + i], 0.f, 1.f) * 255;
		delete[] data;
	}

	IntType FrameBuffer::GetPixelSize(BoolType color) const
	{
		if (color)
			return 4 * (hdr ? sizeof(float) : sizeof(uchar));
		else
			return sizeof(uint32_t);
	}
}
