#pragma once
#include "Common.hpp"

#define PAGE_SIZE 4096

namespace CppProject
{
	struct Sprite;
	struct TexturePageLocation;
	struct Texture;

	// Combines loaded images into a sequence of texture pages.
	struct TexturePage
	{
		TexturePage();
		~TexturePage();

		// Returns the OpenGL texture of the page, creating it if needed.
		Texture* GetTexture();

		// Adds a new image to the last or new texture page, returning the location.
		static TexturePageLocation* Add(const QImage& image);

		// Saves all texture pages for debugging purposes.
		static void Debug();

		IntType size;
		QImage image;
		Texture* texture = nullptr;
		TexturePageLocation* defaultLocation = nullptr;
		QVector<QRect> rects;

		// Stores the last spot an image with a size was placed
		struct LastFreeKey
		{
			int wid, hei;

			LastFreeKey(QSize size) : wid(size.width()), hei(size.height()) {}

			bool operator<(const LastFreeKey& other) const
			{
				return (other.wid * other.hei < wid* hei);
			}
		};
		QMap<LastFreeKey, QPoint> lastFree;

		static IntType pageSize;
		static QStack<TexturePage*> pages;
	};

	// Location in a texture page.
	struct TexturePageLocation
	{
		TexturePageLocation(TexturePage* page, QRect rect, UvRect uvRect);
		~TexturePageLocation();

		// Returns a location from an integer ID, or nullptr if not found.
		static TexturePageLocation* Find(IntType id) { return idMap.value(id, nullptr); }

		IntType id;
		TexturePage* page = nullptr;
		QRect rect;
		UvRect uvRect;

		static QHash<IntType, TexturePageLocation*> idMap;
		static IntType nextId;
	};
}