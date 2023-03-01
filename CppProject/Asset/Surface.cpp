#include "Surface.hpp"

#include "AppHandler.hpp"
#include "AppWindow.hpp"
#include "Render/GraphicsApiHandler.hpp"

namespace CppProject
{
	Surface::Surface(QSize size, BoolType depthBuffer, BoolType hdr) : Asset(ID_Surface)
	{
		frameBuffer = new FrameBuffer(depthBuffer, hdr);
		if (size.width() && size.height())
			Resize(size);
	}

	Surface::~Surface()
	{
		delete frameBuffer;
	}

	QImage Surface::ToImage()
	{
		QImage img(size.width(), size.height(), QImage::Format_RGBA8888);
		frameBuffer->CopyColorData(img.bits());
		return img;
	}

	QColor Surface::GetColor(QPoint point, BoolType cache)
	{
		point.rx() = std::clamp(point.x(), 0, size.width() - 1);
		point.ry() = std::clamp(point.y(), 0, size.height() - 1);
	
		if (!colorData.size())
			colorData.resize(size.width() * size.height() * 4);

		if (!cacheColorData)
			frameBuffer->CopyColorData(colorData.data());

		IntType colorIndex = (point.y() * size.width() + point.x()) * 4;
		QColor color = QColor(
			colorData[colorIndex],
			colorData[colorIndex + 1],
			colorData[colorIndex + 2],
			colorData[colorIndex + 3]
		);

		cacheColorData = cache;
		if (!cache)
			colorData.clear();

		return color;
	}

	void Surface::ClearColorCache()
	{
		cacheColorData = false;
	}

	float Surface::GetDepth(QPoint point, BoolType cache)
	{
		if (!frameBuffer->depthBuffer)
		{
			WARNING("GetDepth on non-depth surface");
			return 0.0;
		}

		point.rx() = std::clamp(point.x(), 0, size.width() - 1);
		point.ry() = std::clamp(point.y(), 0, size.height() - 1);

		if (!depthStencilData.size())
			depthStencilData.resize(size.width() * size.height());

		if (!cacheDepthStencilData)
			frameBuffer->CopyData(false, (uchar*)depthStencilData.data());

	#if API_D3D11
		float depth = ((depthStencilData.value(point.y() * size.width() + point.x()) & 0xFFFFFF) / (RealType)0xFFFFFF + 1.0) / 2.0;
	#else
		float depth = (depthStencilData.value(point.y() * size.width() + point.x()) >> 8) / (RealType)0xFFFFFF;
	#endif

		cacheDepthStencilData = cache;
		if (!cache)
			depthStencilData.clear();

		return depth;
	}

	void Surface::ClearDepthCache()
	{
		cacheDepthStencilData = false;
	}

	void Surface::Resize(QSize newSize)
	{
		if (size == newSize)
			return;

		size = newSize;
		ortho = Matrix::Ortho(0, size.width(), size.height(), 0, -100, 100);
		colorData.clear();
		depthStencilData.clear();
		cacheColorData = cacheDepthStencilData = false;
		frameBuffer->Update(size);
	}

	bool Surface::BeginUse(QSize expectedSize)
	{
		// Resize if needed
		if (expectedSize.width() > 0 && expectedSize.height() > 0 && size != expectedSize)
			Resize(expectedSize);

		if (!frameBuffer->BeginUse())
			return false;

		GFX->matrixP = ortho;
		return true;
	}

	bool Surface::EndUse()
	{
		frameBuffer->EndUse();
		return true;
	}
}