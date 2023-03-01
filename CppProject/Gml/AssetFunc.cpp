#include "Generated/GmlFunc.hpp"

#include "Asset/Surface.hpp"
#include "Asset/Sprite.hpp"
#include "Asset/Script.hpp"
#include "Asset/Font.hpp"
#include "AppHandler.hpp"
#include "Render/GraphicsApiHandler.hpp"

namespace CppProject
{
	VarType asset_get_index(StringType name)
	{
		return Asset::subAssetNameIdMap.value(name, -1);
	}

	void instance_activate_object(VarType)
	{
		// Do nothing
	}

	VarType instance_create_depth(IntType, IntType, IntType, VarType)
	{
		// Replaced by new x()
		return -1;
	}

	void instance_deactivate_object(VarType)
	{
		// Do nothing
	}

	void instance_destroy(ScopeAny self, VarArgs args)
	{
		if (args.Size() > 0)
		{
			if (Object* obj = ObjOpt(args[0]))
				delete obj;
		}
		else
			delete self.object;
	}

	BoolType instance_exists(VarType id)
	{
		if (Object::objectIdsMap.contains(id)) // Sub-asset id
			return !Object::objectIdsMap.value(id).isEmpty();

		else // Instance id
			return (ObjOpt(id) != nullptr);
	}

	IntType instance_number(VarType subAssetId)
	{
		return (Object::objectIdsMap.value(subAssetId).size());
	}

	void font_add_enable_aa(BoolType enabled)
	{
		Font::fontAA = enabled;
	}

	IntType font_add_sprite_ext(IntType id, StringType string_map, BoolType, IntType sep)
	{
		if (Sprite* spr = FindSprite(id))
			return (new SpriteFont(spr, string_map, sep))->id;
		return -1;
	}

	IntType font_add(StringType name, IntType size, BoolType bold, BoolType italic, IntType first, IntType last)
	{
		if (QFile::exists(name))
			return (new Font(name, size, bold, italic, first, last))->id;
		return -1;
	}

	void font_delete(IntType id)
	{
		if (Font* font = FindFont(id))
			delete font;
	}

	BoolType font_exists(IntType id)
	{
		return (FindFont(id) != nullptr);
	}

	VarType script_execute(ScopeAny scope, VarArgs args)
	{
		if (Script* script = FindScript(args[0]))
			return script->Execute(scope->id, scope.otherId, VarArgs(args, 1));
		
		return VarType();
	}

	BoolType script_exists(IntType id)
	{
		return (FindScript(id) != nullptr);
	}

	StringType script_get_name(IntType id)
	{
		if (Script* script = FindScript(id))
			return Asset::subAssetNameIdMap.key(script->subAssetId);

		return "";
	}

	IntType sprite_add(StringType file, IntType, BoolType, BoolType, IntType xorig, IntType yorig)
	{
		if (QFile::exists(file))
			return (new Sprite(file, { (int)xorig, (int)yorig }))->id;
		return -1;
	}

	IntType sprite_create_from_surface(IntType id, IntType x, IntType y, IntType w, IntType h, BoolType, BoolType, IntType xorig, IntType yorig)
	{
		if (Surface* surf = FindSurface(id))
		{
			GFX->SubmitBatch();
			if (x != 0 || y != 0 || w != surf->size.width() || h != surf->size.height()) // Crop
				return (new Sprite(surf, QRect(x, y, w, h), { (int)xorig, (int)yorig }))->id;
			else
				return (new Sprite(surf, { (int)xorig, (int)yorig }))->id;
		}
		return -1;
	}

	void sprite_delete(IntType id)
	{
		if (Sprite* spr = FindSprite(id))
			delete spr;
	}

	IntType sprite_duplicate(IntType id)
	{
		if (Sprite* spr = FindSprite(id))
			return (new Sprite(spr))->id;
		return -1;
	}

	BoolType sprite_exists(IntType id)
	{
		return (FindSprite(id) != nullptr);
	}

	IntType sprite_get_height(IntType id)
	{
		if (Sprite* spr = FindSprite(id))
			return spr->size.height();
		return -1;
	}

	IntType sprite_get_number(IntType id)
	{
		if (Sprite* spr = FindSprite(id))
			return spr->frames.size();
		return -1;
	}

	IntType sprite_get_texture(IntType id, IntType subimg)
	{
		if (id == 0)
			return -1;
		if (Sprite* spr = FindSprite(id))
				return spr->GetTexture(subimg);
		return -1;
	}

	IntType sprite_get_width(IntType id)
	{
		if (Sprite* spr = FindSprite(id))
			return spr->size.width();
		return -1;
	}

	void sprite_set_offset(IntType id, IntType x, IntType y)
	{
		if (Sprite* spr = FindSprite(id))
			spr->origin = { (int)x, (int)y };
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