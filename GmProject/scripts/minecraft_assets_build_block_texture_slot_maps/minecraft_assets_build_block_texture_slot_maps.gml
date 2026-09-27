/// @desc Builds face texture lookups while preserving the render-model fallback order.

function minecraft_assets_build_block_texture_slot_maps()
{
	ds_map_clear(mc_assets.block_texture_slot_map)
	ds_map_clear(mc_assets.block_texture_opaque_slot_map)

	var staticcount, animatedcount, texturename, basename;
	staticcount = ds_list_size(mc_assets.block_texture_list[e_block_sheet.STATIC16])
	animatedcount = ds_list_size(mc_assets.block_texture_ani_list)

	// Each value encodes its texture-sheet page and slot. Add fallbacks from lowest
	// to highest priority. Traversing backwards preserves
	// ds_list_find_index's first-match behavior when a list has duplicate names.
	for (var t = animatedcount - 1; t >= 0; t--)
	{
		texturename = mc_assets.block_texture_ani_list[|t]
		basename = minecraft_assets_block_texture_tag_base(texturename, " nocull")
		if (!is_undefined(basename))
		{
			mc_assets.block_texture_slot_map[?basename] = minecraft_assets_block_texture_slot_encode(e_block_sheet.ANIMATED, t)
			mc_assets.block_texture_opaque_slot_map[?basename] = minecraft_assets_block_texture_slot_encode(e_block_sheet.ANIMATED, t)
		}
	}

	for (var t = animatedcount - 1; t >= 0; t--)
	{
		texturename = mc_assets.block_texture_ani_list[|t]
		basename = minecraft_assets_block_texture_tag_base(texturename, " opaque")
		if (!is_undefined(basename))
		{
			mc_assets.block_texture_slot_map[?basename] = minecraft_assets_block_texture_slot_encode(e_block_sheet.ANIMATED, t)
			mc_assets.block_texture_opaque_slot_map[?basename] = minecraft_assets_block_texture_slot_encode(e_block_sheet.ANIMATED, t)
		}
	}

	for (var t = animatedcount - 1; t >= 0; t--)
	{
		texturename = mc_assets.block_texture_ani_list[|t]
		mc_assets.block_texture_slot_map[?texturename] = minecraft_assets_block_texture_slot_encode(e_block_sheet.ANIMATED, t)
		mc_assets.block_texture_opaque_slot_map[?texturename] = minecraft_assets_block_texture_slot_encode(e_block_sheet.ANIMATED, t)
	}

	for (var t = staticcount - 1; t >= 0; t--)
	{
		texturename = mc_assets.block_texture_list[e_block_sheet.STATIC16][|t]
		mc_assets.block_texture_slot_map[?texturename] = minecraft_assets_block_texture_slot_encode(e_block_sheet.STATIC16, t)
		mc_assets.block_texture_opaque_slot_map[?texturename] = minecraft_assets_block_texture_slot_encode(e_block_sheet.STATIC16, t)
	}

	for (var t = staticcount - 1; t >= 0; t--)
	{
		texturename = mc_assets.block_texture_list[e_block_sheet.STATIC16][|t]
		basename = minecraft_assets_block_texture_tag_base(texturename, " nocull")
		if (!is_undefined(basename))
		{
			mc_assets.block_texture_slot_map[?basename] = minecraft_assets_block_texture_slot_encode(e_block_sheet.STATIC16, t)
			mc_assets.block_texture_opaque_slot_map[?basename] = minecraft_assets_block_texture_slot_encode(e_block_sheet.STATIC16, t)
		}
	}

	for (var t = staticcount - 1; t >= 0; t--)
	{
		texturename = mc_assets.block_texture_list[e_block_sheet.STATIC16][|t]
		basename = minecraft_assets_block_texture_tag_base(texturename, " noalpha")
		if (!is_undefined(basename))
		{
			mc_assets.block_texture_slot_map[?basename] = minecraft_assets_block_texture_slot_encode(e_block_sheet.STATIC16, t)
			mc_assets.block_texture_opaque_slot_map[?basename] = minecraft_assets_block_texture_slot_encode(e_block_sheet.STATIC16, t)
		}
	}

	for (var t = staticcount - 1; t >= 0; t--)
	{
		texturename = mc_assets.block_texture_list[e_block_sheet.STATIC16][|t]
		basename = minecraft_assets_block_texture_tag_base(texturename, " opaque")
		if (!is_undefined(basename))
			mc_assets.block_texture_opaque_slot_map[?basename] = minecraft_assets_block_texture_slot_encode(e_block_sheet.STATIC16, t)
	}

	// High-resolution pages
	for (var size = e_block_sheet.STATIC32; size < e_block_sheet.static_amount; size++)
	{
		var texturecount = ds_list_size(mc_assets.block_texture_list[size])
		for (var t = texturecount - 1; t >= 0; t--)
		{
			texturename = mc_assets.block_texture_list[size][|t]
			mc_assets.block_texture_slot_map[?texturename] = minecraft_assets_block_texture_slot_encode(size, t)
			mc_assets.block_texture_opaque_slot_map[?texturename] = minecraft_assets_block_texture_slot_encode(size, t)
		}
	}
}
