#include "TexturePage.hpp"

#include "Texture.hpp"
#include "Asset/Shader.hpp"
#include "Generated/GmlFunc.hpp"

namespace CppProject
{
	QStack<TexturePage*> TexturePage::pages;
	IntType TexturePage::pageSize = PAGE_SIZE;
	IntType TexturePageLocation::nextId = 1000000;
	QHash<IntType, TexturePageLocation*> TexturePageLocation::idMap;
	static constexpr int PAGE_GUTTER = 1;

	TexturePage::TexturePage()
	{
		while (pageSize > 0)
		{
			size = pageSize;
			image = QImage(size, size, QImage::Format_RGBA8888);
			if (!image.isNull())
				break;
			
			WARNING("Could not allocate texture page with size " + NumStr(size) + "x" + NumStr(size));
			pageSize >>= 1;
			WARNING("Decreasing size");
		}

		// Add 1x1 white pixel in top left as default texture
		if (!image.isNull())
		{
			image.fill(Qt::transparent);
			uchar* imgBits = image.bits();
			imgBits[0] = 255;
			imgBits[1] = 255;
			imgBits[2] = 255;
			imgBits[3] = 255;
			freeRegion = QRegion(0, 0, size, size);
			freeRegion -= QRegion(0, 0, 1, 1);

			defaultLocation = new TexturePageLocation(
				this,
				{ 0, 0, 1, 1 },
				{ 0, 0, 1, 1 },
				{ 0.f, 0.f, 1.f / size, 1.f / size }
			);
		}

		// Select as shader page
		if (!Shader::currentPage)
			Shader::currentPage = this;
	}

	TexturePage::~TexturePage()
	{
		deleteAndReset(texture);
	}

	Texture* TexturePage::GetTexture()
	{
		if (!texture && !image.isNull())
			texture = new Texture(image);
		return texture;
	}

	bool TexturePage::Allocate(QSize imageSize, QRect& rect, QRect& allocatedRect)
	{
		QSize allocatedSize(imageSize.width() + PAGE_GUTTER * 2, imageSize.height() + PAGE_GUTTER * 2);
		int best = -1;
		int bestShortSide = size;
		int bestLongSide = size;

		// Choose the tightest fitting free rectangle
		QVector<QRect> freeRects = freeRegion.rects();
		for (int i = 0; i < freeRects.size(); i++)
		{
			const QRect& freeRect = freeRects[i];
			if (freeRect.width() < allocatedSize.width() || freeRect.height() < allocatedSize.height())
				continue;

			int shortSide = std::min(freeRect.width() - allocatedSize.width(), freeRect.height() - allocatedSize.height());
			int longSide = std::max(freeRect.width() - allocatedSize.width(), freeRect.height() - allocatedSize.height());
			if (shortSide < bestShortSide || (shortSide == bestShortSide && longSide < bestLongSide))
			{
				best = i;
				bestShortSide = shortSide;
				bestLongSide = longSide;
			}
		}

		if (best < 0)
			return false;

		QRect freeRect = freeRects[best];
		allocatedRect = { freeRect.x(), freeRect.y(), allocatedSize.width(), allocatedSize.height() };
		rect = { allocatedRect.x() + PAGE_GUTTER, allocatedRect.y() + PAGE_GUTTER, imageSize.width(), imageSize.height() };
		freeRegion -= QRegion(allocatedRect);

		return true;
	}

	void TexturePage::Release(QRect allocatedRect)
	{
		freeRegion |= QRegion(allocatedRect);
	}

	TexturePageLocation* TexturePage::Add(const QImage& image)
	{
		if (image.isNull())
			return nullptr;

		TexturePage* page = nullptr;
		QRect rect, allocatedRect;
		for (IntType p = pages.size() - 1; p >= 0; p--)
		{
			TexturePage* currentPage = pages[p];
			if (currentPage->Allocate(image.size(), rect, allocatedRect))
			{
				page = currentPage;
				break;
			}
		}

		if (!page)
		{
			page = new TexturePage;
			if (!page->Allocate(image.size(), rect, allocatedRect))
			{
				delete page;
				return nullptr;
			}
			pages.push(page);
		}

		if (!QRect(0, 0, page->size, page->size).contains(allocatedRect))
		{
			page->Release(allocatedRect);
			return nullptr;
		}

		deleteAndReset(page->texture);

		// Copy the image and duplicate its edge pixels into the gutter
		for (int y = -PAGE_GUTTER; y < image.height() + PAGE_GUTTER; y++)
		{
			const uchar* srcRow = image.constScanLine(qBound(0, y, image.height() - 1));
			uchar* dstRow = page->image.scanLine(rect.y() + y);
			memcpy(dstRow + (rect.x() - PAGE_GUTTER) * 4, srcRow, 4);
			memcpy(dstRow + rect.x() * 4, srcRow, image.width() * 4);
			memcpy(dstRow + (rect.x() + image.width()) * 4, srcRow + (image.width() - 1) * 4, 4);
		}

		return new TexturePageLocation(
			page,
			rect,
			allocatedRect,
			{
				(RealType)rect.topLeft().x() / page->size,
				(RealType)rect.topLeft().y() / page->size,
				(RealType)rect.width() / page->size,
				(RealType)rect.height() / page->size
			}
		);
	}

	void TexturePage::Debug()
	{
		int p = 1;
		for (TexturePage* page : pages)
		{
			if (!page->image.isNull())
				page->image.save((QString)gmlGlobal::working_directory + "/TexturePages/" + NumStr(p) + ".png");
			p++;
		}
		DEBUG("Saved texture pages");
	}

	TexturePageLocation::TexturePageLocation(TexturePage* page, QRect rect, QRect allocatedRect, UvRect uvRect) :
		page(page), rect(rect), allocatedRect(allocatedRect), uvRect(uvRect)
	{
		id = nextId++;
		idMap[id] = this;
	}

	TexturePageLocation::~TexturePageLocation()
	{
		idMap.remove(id);
		if (!allocatedRect.isEmpty())
			page->Release(allocatedRect);
	}
}
