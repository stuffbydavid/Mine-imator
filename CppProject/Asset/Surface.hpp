#pragma once
#include "Asset.hpp"
#include "Render/Matrix.hpp"
#include "Render/FrameBuffer.hpp"

namespace CppProject
{
	struct AppWindow;

	// Surface asset
	struct Surface : Asset
	{
		Surface(QSize size = {}, BoolType depthBuffer = true, BoolType hdr = false);
		~Surface();

		// Returns the surface as a QImage.
		QImage ToImage();

		// Returns the color value of a surface pixel, optionally the result is cached for multiple calls.
		QColor GetColor(QPoint point, BoolType cache = true);

		// Clears the color cache created in GetColor().
		void ClearColorCache();

		// Returns the depth value from 0-1 of a surface pixel, the result is cached for multiple calls.
		float GetDepth(QPoint point, BoolType cache = true);

		// Clears the depth cache created in GetDepth().
		void ClearDepthCache();

		// Resizes the surface and clears its framebuffer.
		void Resize(QSize newSize);

		// Starts/stops rendering to the surface, returns whether successful.
		bool BeginUse(QSize expectedSize = {});
		bool EndUse();

		FrameBuffer* frameBuffer = nullptr;
		QSize size;
		Matrix ortho;
		QVector<uchar> colorData;
		QVector<uint32_t> depthStencilData;
		BoolType cacheColorData = false, cacheDepthStencilData = false;
	};
}