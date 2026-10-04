#include "Asset/Sprite.hpp"
#include "Render/GraphicsApiHandler.hpp"
#include "Render/TexturePage.hpp"

namespace CppProject
{
	void texture_page_set_current(IntType index)
	{
		TexturePage::SetCurrent(index);
	}

	IntType texture_page_get_current()
	{
		return TexturePage::currentPageIndex;
	}

	IntType texture_page_create()
	{
		return TexturePage::CreatePage();
	}

	BoolType texture_page_add(IntType id, IntType index)
	{
		Sprite* sprite = FindSprite(id);
		if (!sprite || index < 0 || index >= TexturePage::pages.size() || !TexturePage::pages[index])
			return false;
		
		GFX->SubmitBatch();

		sprite->useTexturePage = true;

		BoolType success = true;
		for (Sprite::Frame* frame : sprite->frames)
		{
			if (frame->pageLoc && frame->pageLoc->page && frame->texturePageIndex == index)
				continue;

			QImage image = (frame->pageLoc && frame->pageLoc->page) ?
				frame->pageLoc->page->image.copy(frame->pageLoc->rect) : frame->image;
			
			TexturePageLocation* location = TexturePage::Add(image, index);
			
			if (!location)
			{
				success = false;
				continue;
			}
			
			// Release the previous slot only after the new allocation succeeds
			deleteAndReset(frame->pageLoc);
			deleteAndReset(frame->texture);

			frame->pageLoc = location;
			frame->texturePageIndex = index;
			frame->image = QImage();
		}

		return success;
	}

	void texture_page_clear(IntType index)
	{
		TexturePage::ClearPage(index);
	}

	void texture_page_destroy(IntType index)
	{
		TexturePage::DestroyPage(index);
	}

	IntType texture_sprite(IntType spr)
	{
		return spr;
	}

	void sprite_set_texture_page(IntType id, BoolType enabled)
	{
		if (Sprite* spr = FindSprite(id))
			spr->useTexturePage = enabled;
	}

	void move_all_to_texture_page()
	{
		Timer tmr;
		IntType num = 0;
		for (Sprite* spr : Sprite::allSprites)
			if (spr->useTexturePage)
				for (Sprite::Frame* frame : spr->frames)
					num += frame->MoveToTexturePage() ? 1 : 0;

		tmr.Print("Moved " + NumStr(num) + " sprites to texture pages");
	}
}
