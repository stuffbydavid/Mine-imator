#pragma once
#include "Common.hpp"
#include "GraphicsApiHandler.hpp"

namespace CppProject
{
	struct AppWindow;

	// Wrapper for a GPU framebuffer.
	struct FrameBuffer
	{
		FrameBuffer(IntType format = 0, BoolType depthBuffer = true);
		~FrameBuffer();

		// Returns the color texture handle of the surface for reading.
		IntType GetColorTexId() const;

		// Updates the framebuffer with the given size.
		void Update(QSize size);

		// Stars using the framebuffer for drawing.
		BoolType BeginUse();

		// Stops using the framebuffer for drawing and prepares a given buffer as a texture.
		void EndUse();

		// Copies the color or depth/stencil data to the given destination.
		void CopyData(BoolType color, uchar* dst);

		// Copies the color data to the given destination with 8 bits for RGBA.
		void CopyColorData(uchar* dst);

		// Returns the total size in bytes for a single pixel of color or depth/stencil data.
		IntType GetPixelSize(BoolType color) const;

		IntType format;
		BoolType depthBuffer;
		QSize size = { 0, 0 };

	#if OS_WINDOWS
		DXGI_FORMAT d3dFormat = DXGI_FORMAT_UNKNOWN;
		ID3D11Texture2D* d3dColorTex = nullptr;
		ID3D11Texture2D* d3dDepthStencilTex = nullptr;
		ID3D11DepthStencilView* d3dDSV = nullptr;
		ID3D11RenderTargetView* d3dRTV = nullptr;
		ID3D11ShaderResourceView* d3dSRV = nullptr;
		IntType d3dSRVId = 0;
	#endif
		GLuint glInternalFormat = 0, glFormat = 0, glType = 0;
		GLuint glFboId = 0, glColorTexId = 0, glDepthStencilRboId = 0;
		QOpenGLContext* fboContext = nullptr;
	};
}