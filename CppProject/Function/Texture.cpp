#include "Asset/Sprite.hpp"

namespace CppProject
{
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
