#pragma once
#include "Common.hpp"

#include <QRegion>

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
		bool Allocate(QSize imageSize, QRect& rect, QRect& allocatedRect);
		void Release(QRect allocatedRect);

		// Adds a new image to the last or new texture page, returning the location.
		static TexturePageLocation* Add(const QImage& image);

		// Saves all texture pages for debugging purposes.
		static void Debug();

		IntType size;
		QImage image;
		Texture* texture = nullptr;
		TexturePageLocation* defaultLocation = nullptr;
		QRegion freeRegion;

		static IntType pageSize;
		static QStack<TexturePage*> pages;
	};

	// Location in a texture page.
	struct TexturePageLocation
	{
		TexturePageLocation(TexturePage* page, QRect rect, QRect allocatedRect, UvRect uvRect);
		~TexturePageLocation();

		// Returns a location from an integer ID, or nullptr if not found.
		static TexturePageLocation* Find(IntType id) { return idMap.value(id, nullptr); }

		IntType id;
		TexturePage* page = nullptr;
		QRect rect;
		QRect allocatedRect;
		UvRect uvRect;

		static QHash<IntType, TexturePageLocation*> idMap;
		static IntType nextId;
	};
}
