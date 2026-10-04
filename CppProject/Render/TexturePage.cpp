#include "TexturePage.hpp"

#include "Texture.hpp"
#include "Asset/Shader.hpp"
#include "Generated/GmlFunc.hpp"

namespace CppProject
{
	QStack<TexturePage*> TexturePage::pages;
	IntType TexturePage::currentPageIndex = -1;
	IntType TexturePage::pageSize = PAGE_SIZE;
	IntType TexturePageLocation::nextId = 1000000;
	QHash<IntType, TexturePageLocation*> TexturePageLocation::idMap;

	static constexpr int PAGE_GUTTER = 1;

	TexturePage::TexturePage()
	{
		// Reduce the page size if the image allocation fails
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
			Clear();

		// Provide a default white pixel for untextured draws
		if (!Shader::currentPage && defaultLocation)
			Shader::currentPage = this;
	}

	TexturePage::~TexturePage()
	{
		// Sprite and font owners may release their locations after the page
		deleteAndReset(defaultLocation);
		for (TexturePageLocation* location : locations)
		{
			TexturePageLocation::idMap.remove(location->id);
			location->id = -1;
			location->page = nullptr;
		}

		// Release the GPU texture and owned overflow chain
		if (Shader::currentPage == this)
			Shader::currentPage = nullptr;

		deleteAndReset(texture);
		deleteAndReset(nextPage);
	}

	IntType TexturePage::CreatePage()
	{
		// Append roots so existing indices are never reused
		pages.push(new TexturePage);
		return pages.size() - 1;
	}

	void TexturePage::SetCurrent(IntType index)
	{
		if (index < 0 || index >= pages.size() || !pages[index])
		{
			WARNING("Texture page index out of range: " + NumStr(index));
			return;
		}

		currentPageIndex = index;
	}

	void TexturePage::ClearPage(IntType index)
	{
		if (index < 0 || index >= pages.size() || !pages[index])
			return;

		// Finish queued draws before invalidating the chain's textures
		GFX->SubmitBatch();

		for (TexturePage* page = pages[index]; page; page = page->nextPage)
			page->Clear();
	}

	void TexturePage::DestroyPage(IntType index)
	{
		if (index < 0 || index >= pages.size() || !pages[index])
			return;

		GFX->SubmitBatch();

		// Remove the root before deleting its linked pages
		TexturePage* page = pages[index];
		pages[index] = nullptr;
		delete page;

		// Prefer the UI page for allocation, then any surviving root
		if (currentPageIndex == index)
			currentPageIndex = !pages.isEmpty() && pages[0] ? 0 : -1;

		for (IntType p = 0; p < pages.size(); p++)
		{
			if (pages[p])
			{
				if (currentPageIndex < 0)
					currentPageIndex = p;
				
				if (!Shader::currentPage)
					Shader::currentPage = pages[p];
				
				break;
			}
		}
	}

	void TexturePage::Clear()
	{
		// Detach live locations so their later destruction cannot release reused space
		deleteAndReset(defaultLocation);
		for (TexturePageLocation* location : locations)
		{
			TexturePageLocation::idMap.remove(location->id);
			location->id = -1;
			location->page = nullptr;
		}

		locations.clear();
		deleteAndReset(texture);

		if (image.isNull())
			return;

		// Reset the allocator and reserve the default white pixel
		image.fill(Qt::transparent);
		memset(image.bits(), 255, 4);
		freeRegion = QRegion(0, 0, size, size) - QRegion(0, 0, 1, 1);
		defaultLocation = new TexturePageLocation(
			this,
			{ 0, 0, 1, 1 },
			{ 0, 0, 1, 1 },
			{ 0.f, 0.f, 1.f / size, 1.f / size }
		);
	}

	Texture* TexturePage::GetTexture()
	{
		if (!texture && !image.isNull())
			texture = new Texture(image);
		
		return texture;
	}

	bool TexturePage::Allocate(QSize imageSize, QRect& rect, QRect& allocatedRect)
	{
		int best = -1;
		int bestShortSide = size;
		int bestLongSide = size;
		QRect bestRect, bestAllocatedRect;

		// Keep large tile sheets aligned through four mip levels
		int alignment = 1;
		if (std::max(imageSize.width(), imageSize.height()) >= 256 &&
			std::min(imageSize.width(), imageSize.height()) >= 16 &&
			imageSize.width() % 16 == 0 && imageSize.height() % 16 == 0)
			alignment = 16;

		// Choose the tightest fitting free rectangle
		QVector<QRect> freeRects = freeRegion.rects();
		for (int i = 0; i < freeRects.size(); i++)
		{
			const QRect& freeRect = freeRects[i];
			int x = ((freeRect.x() + PAGE_GUTTER + alignment - 1) / alignment) * alignment;
			int y = ((freeRect.y() + PAGE_GUTTER + alignment - 1) / alignment) * alignment;
			QRect candidate(freeRect.x(), freeRect.y(),
				x - freeRect.x() + imageSize.width() + PAGE_GUTTER,
				y - freeRect.y() + imageSize.height() + PAGE_GUTTER);
			if (freeRect.width() < candidate.width() || freeRect.height() < candidate.height())
				continue;

			int shortSide = std::min(freeRect.width() - candidate.width(), freeRect.height() - candidate.height());
			int longSide = std::max(freeRect.width() - candidate.width(), freeRect.height() - candidate.height());
			if (shortSide < bestShortSide || (shortSide == bestShortSide && longSide < bestLongSide))
			{
				best = i;
				bestShortSide = shortSide;
				bestLongSide = longSide;
				bestRect = { x, y, imageSize.width(), imageSize.height() };
				bestAllocatedRect = candidate;
			}
		}

		if (best < 0)
			return false;

		allocatedRect = bestAllocatedRect;
		rect = bestRect;
		freeRegion -= QRegion(allocatedRect);

		return true;
	}

	void TexturePage::Release(QRect allocatedRect)
	{
		if (allocatedRect.isEmpty())
			return;

		// Clear released pixels so deleted textures do not remain in page dumps or mipmaps
		if (texture)
		{
			GFX->SubmitBatch();
			deleteAndReset(texture);
		}

		for (int y = allocatedRect.top(); y <= allocatedRect.bottom(); y++)
			memset(image.scanLine(y) + allocatedRect.x() * 4, 0, allocatedRect.width() * 4);
		
		freeRegion |= QRegion(allocatedRect);
	}

	TexturePageLocation* TexturePage::Add(const QImage& image, IntType index)
	{
		// Resolve the root and reject images that require a standalone texture
		if (index < 0)
			index = currentPageIndex;

		if (image.isNull() || index < 0 || index >= pages.size() || !pages[index])
			return nullptr;

		TexturePage* page = pages[index];
		if (image.width() + PAGE_GUTTER * 2 > page->size ||
			image.height() + PAGE_GUTTER * 2 > page->size)
			return nullptr;

		// Search only this root's chain, extending it when all pages are full
		QRect rect, allocatedRect;
		while (!page->Allocate(image.size(), rect, allocatedRect))
		{
			if (page->nextPage)
			{
				page = page->nextPage;
				continue;
			}

			// Verify a fresh page can fit the image before linking it
			TexturePage* next = new TexturePage;
			if (!next->Allocate(image.size(), rect, allocatedRect))
			{
				delete next;
				return nullptr;
			}

			page->nextPage = next;
			page = next;
			break;
		}

		if (!QRect(0, 0, page->size, page->size).contains(allocatedRect))
		{
			page->Release(allocatedRect);
			return nullptr;
		}

		// Finish queued draws before rebuilding the modified page's GPU texture
		if (page->texture)
		{
			GFX->SubmitBatch();
			deleteAndReset(page->texture);
		}

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
		// Flatten the root chains into sequential image filenames
		int p = 1;
		for (TexturePage* page : pages)
		{
			for (; page; page = page->nextPage)
			{
				if (!page->image.isNull())
					page->image.save((QString)gmlGlobal::working_directory + "/TexturePages/" + NumStr(p) + ".png");
				p++;
			}
		}

		DEBUG("Saved texture pages");
	}

	TexturePageLocation::TexturePageLocation(TexturePage* page, QRect rect, QRect allocatedRect, UvRect uvRect) :
		page(page), rect(rect), allocatedRect(allocatedRect), uvRect(uvRect)
	{
		id = nextId++;
		idMap[id] = this;
		page->locations.insert(this);
	}

	TexturePageLocation::~TexturePageLocation()
	{
		idMap.remove(id);

		// Cleared or destroyed pages have already detached this location
		if (page)
		{
			page->locations.remove(this);
			if (!allocatedRect.isEmpty())
				page->Release(allocatedRect);
		}
	}
}
