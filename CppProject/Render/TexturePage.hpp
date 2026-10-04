#pragma once
#include "Common.hpp"

#include <QRegion>
#include <QSet>

#define PAGE_SIZE 4096

namespace CppProject
{
	struct Sprite;
	struct TexturePageLocation;
	struct Texture;

	// Combines loaded images into independent texture page chains
	struct TexturePage
	{
		TexturePage();
		~TexturePage();

		// Returns the GPU texture, creating it from the page image if needed.
		Texture* GetTexture();

		// Reserves an image rectangle including its edge gutter.
		bool Allocate(QSize imageSize, QRect& rect, QRect& allocatedRect);

		// Returns an allocated rectangle to the free region.
		void Release(QRect allocatedRect);

		// Creates an independent root page and returns its stable index.
		static IntType CreatePage();

		// Selects the root page for newly created images.
		static void SetCurrent(IntType index);

		// Adds an image to a root page or its overflow chain.
		// A negative index uses the current root page.
		static TexturePageLocation* Add(const QImage& image, IntType index = -1);

		// Clears the root and linked pages without destroying the chain.
		static void ClearPage(IntType index);

		// Destroys the root and all linked pages without shifting other indices.
		static void DestroyPage(IntType index);

		// Clears this page and invalidates locations still owned by sprites or fonts.
		void Clear();

		// Saves all root and linked pages for debugging.
		static void Debug();

		IntType size = 0;
		QImage image;
		Texture* texture = nullptr;
		TexturePageLocation* defaultLocation = nullptr;
		QRegion freeRegion;
		TexturePage* nextPage = nullptr; // Owned overflow page
		QSet<TexturePageLocation*> locations; // Non-owning references for invalidation

		static IntType pageSize;
		static QStack<TexturePage*> pages; // Root pages only, destroyed entries remain null
		static IntType currentPageIndex;
	};

	// Image location owned by a sprite or font, detached when its page is cleared.
	struct TexturePageLocation
	{
		TexturePageLocation(TexturePage* page, QRect rect, QRect allocatedRect, UvRect uvRect);
		~TexturePageLocation();

		// Returns a live location from its ID, or nullptr if not found.
		static TexturePageLocation* Find(IntType id) { return idMap.value(id, nullptr); }

		IntType id;
		TexturePage* page = nullptr;
		QRect rect; // Image pixels without the gutter
		QRect allocatedRect; // Reserved region including the gutter
		UvRect uvRect;

		static QHash<IntType, TexturePageLocation*> idMap;
		static IntType nextId;
	};
}
