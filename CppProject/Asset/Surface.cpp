#include "Surface.hpp"

#include "Generated/Scripts.hpp"

#include "AppHandler.hpp"
#include "AppWindow.hpp"
#include "Render/GraphicsApiHandler.hpp"

#include <QFloat16>

namespace CppProject
{
	Surface::Surface(QSize size, IntType format, BoolType depthBuffer, BoolType depthOnly) : Asset(ID_Surface)
	{
		frameBuffer = new FrameBuffer(format, depthBuffer, depthOnly);
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

	VecType Surface::GetColorFloat(QPoint point, BoolType cache)
	{
		if (size.isEmpty())
			return { 0, 0, 0, 1 };

		IntType channels = 0;
		BoolType half = false;
		switch (frameBuffer->format)
		{
			case surface_r16float:		channels = 1; half = true; break;
			case surface_rgba16float:	channels = 4; half = true; break;
			case surface_r32float:		channels = 1; break;
			case surface_rg32float:		channels = 2; break;
			case surface_rgba32float:	channels = 4; break;
		}

		if (!channels)
		{
			QColor color = GetColor(point, cache);
			return { color.redF(), color.greenF(), color.blueF(), color.alphaF() };
		}

		point.rx() = std::clamp(point.x(), 0, size.width() - 1);
		point.ry() = std::clamp(point.y(), 0, size.height() - 1);
		
		IntType pixelSize = frameBuffer->GetPixelSize(true);
		if (colorFloatData.isEmpty())
			colorFloatData.resize(size.width() * size.height() * pixelSize);
		
		if (!cacheColorFloatData)
			frameBuffer->CopyData(true, colorFloatData.data());
		
		const uchar* pixel = colorFloatData.constData() + (point.y() * size.width() + point.x()) * pixelSize;
		RealType values[4] = { 0, 0, 0, 1 };
		for (IntType c = 0; c < channels; c++)
		{
			if (half)
			{
				qfloat16 value;
				memcpy(&value, pixel + c * sizeof(value), sizeof(value));
				values[c] = (float)value;
			}
			else
			{
				float value;
				memcpy(&value, pixel + c * sizeof(value), sizeof(value));
				values[c] = value;
			}
		}
		
		cacheColorFloatData = cache;
		if (!cache)
			colorFloatData.clear();
		
		return { values[0], values[1], values[2], values[3] };
	}

	void Surface::ClearColorCache()
	{
		cacheColorData = cacheColorFloatData = false;
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

		uint32_t packedDepth = depthStencilData.value(point.y() * size.width() + point.x());
		float depth = 0.f;
		if (frameBuffer->depthOnly)
		{
			memcpy(&depth, &packedDepth, sizeof(depth));
			if (IS_D3D11)
				depth = (depth + 1.f) * 0.5f;
		}
		else if (IS_D3D11)
			depth = ((packedDepth & 0xFFFFFF) / (RealType)0xFFFFFF + 1.0) / 2.0;

		else if (IS_OPENGL)
			depth = (packedDepth >> 8) / (RealType)0xFFFFFF;

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
		colorFloatData.clear();
		depthStencilData.clear();

		cacheColorData = cacheColorFloatData = cacheDepthStencilData = false;

		frameBuffer->Update(size);
	}

	bool Surface::BeginUse(QSize expectedSize)
	{
		// Resize if needed
		if (expectedSize.width() > 0 && expectedSize.height() > 0 && size != expectedSize)
			Resize(expectedSize);
		
		ClearColorCache();

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
