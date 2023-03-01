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
			uchar* imgBits = image.bits();
			imgBits[0] = 255;
			imgBits[1] = 255;
			imgBits[2] = 255;
			imgBits[3] = 255;
			rects.append({ 0, 0, 1, 1 });

			defaultLocation = new TexturePageLocation(
				this,
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

	TexturePageLocation* TexturePage::Add(const QImage& image)
	{
		// Image invalid or too big, not supported for texture pages
		if (image.isNull() || image.width() > pageSize || image.height() > pageSize)
			return nullptr;

		QSize imageSize = image.size();
		TexturePage* page = nullptr;
		QPoint pos;

		// Find existing page location
		IntType numPages = pages.size();
		if (numPages)
		{
			for (IntType p = numPages - 1; p >= 0; p--)
			{
				TexturePage* currentPage = pages[p];
				bool free = true;
				pos = currentPage->lastFree.value(imageSize, { 0, 0 });

				while (true)
				{
					QPoint moveVec = { 16, 16 };
					QRect rect = { pos, imageSize };

					// Check rectangles
					free = true;
					for (const QRect& otherRect : currentPage->rects)
					{
						if (otherRect.intersects(rect))
						{
							// Snap to rectangle right
							moveVec.rx() = (otherRect.right() - pos.x()) + 1;
							free = false;
							break;
						}
					}

					// Move rectangle
					if (!free)
					{
						pos.rx() += moveVec.x();
						if (pos.x() + imageSize.width() >= currentPage->size) // Next column
						{
							pos.rx() = 0;
							pos.ry() += moveVec.y();
							if (pos.y() + imageSize.height() >= currentPage->size) // No space in page, move to next
								break;
						}
					}
					else
						break;
				}

				// Found free spot
				if (free)
				{
					currentPage->lastFree[imageSize] = pos;
					page = currentPage;
					break;
				}
			}

			if (page)
				deleteAndReset(page->texture);
		}

		// Add new page
		if (!page)
		{
			page = new TexturePage;
			pos = { 0, 1 };
			pages.push(page);
		}

		// Write sprite on page
		const uchar* srcBits = image.constBits();
		uchar* dstBits = page->image.bits();

		for (int y = 0; y < image.height(); y++)
		{
			for (int x = 0; x < image.width(); x++)
			{
				if (pos.x() + x >= page->size || pos.y() + y >= page->size)
					continue;

				IntType srcIndex = y * image.width() + x;
				IntType dstIndex = (pos.y() + y) * page->size + (pos.x() + x);
				srcIndex *= 4;
				dstIndex *= 4;
				dstBits[dstIndex + 0] = srcBits[srcIndex + 0];
				dstBits[dstIndex + 1] = srcBits[srcIndex + 1];
				dstBits[dstIndex + 2] = srcBits[srcIndex + 2];
				dstBits[dstIndex + 3] = srcBits[srcIndex + 3];
			}
		}

		// Create location
		QRect rect = { pos, imageSize };
		page->rects.append(rect.adjusted(0, 0, 1, 1));
		return new TexturePageLocation(
			page,
			rect,
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

	TexturePageLocation::TexturePageLocation(TexturePage* page, QRect rect, UvRect uvRect) :
		page(page), rect(rect), uvRect(uvRect)
	{
		id = nextId++;
		idMap[id] = this;
	}

	TexturePageLocation::~TexturePageLocation()
	{
		idMap.remove(id);

		// Remove matching rectangle from page
		for (auto it = page->rects.begin(); it != page->rects.end(); it++)
		{
			if ((*it).topLeft() == rect.topLeft())
			{
				int at = it - page->rects.begin();
				page->rects.removeAt(at);
				return;
			}
		}

		//page->lastFree.remove(location.rect.size());
	}
}