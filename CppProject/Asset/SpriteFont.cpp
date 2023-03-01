#include "Font.hpp"
#include "Type/StringType.hpp"
#include "Render/TexturePage.hpp"
#include "Asset/Shader.hpp"
#include "Sprite.hpp"

namespace CppProject
{
	SpriteFont::SpriteFont(Sprite* spr, StringType chars, IntType sep) : Font()
	{
		if (spr->frames.size() != chars.GetLength())
			FATAL("SpriteFont: Number of frames and input string mismatch.");

		TexturePage* page = spr->frames[0]->pageLoc->page;
		const uchar* bits = page->image.constBits();
		QSize frameSize = spr->frames[0]->pageLoc->rect.size();
		height = frameSize.height() - 2;

		// Scan characters and find dimensions
		for (IntType f = 0; f < spr->frames.size(); f++)
		{
			Sprite::Frame* frame = spr->frames[f];
			TexturePageLocation* frameLoc = frame->pageLoc;
			IntType startX = frameLoc->rect.width(), endX = 0;

			for (IntType y = 0; y < frameLoc->rect.height(); y++)
			{
				for (IntType x = 0; x < frameLoc->rect.width(); x++)
				{
					IntType px = frameLoc->rect.left() + x;
					IntType py = frameLoc->rect.top() + y;
					uchar alpha = bits[(py * page->size + px) * 4 + 3];
					if (alpha > 0)
					{
						startX = std::min(startX, x);
						endX = std::max(endX, x + 1);
					}
				}
			}

			// Create glyph info
			const UvRect& uv = frameLoc->uvRect;
			IntType width = std::max(IntType(1), endX - startX);

			glyphMap[chars.At(f).unicode()] = {
				uv.x, uv.y, uv.x + uv.w, uv.y + uv.h,
				{ 0, (int)height },
				frameSize,
				width + sep
			};
		}

		// 0,0,1,1 rect is passed to the shader, the vertices will have pre-transformed UVs
		pageLoc = new TexturePageLocation(page, QRect(0, 0, page->size, page->size), { 0.0, 0.0, 1.0, 1.0 });
	}
}
