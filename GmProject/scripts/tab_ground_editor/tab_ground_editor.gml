/// tab_ground_editor()

function tab_ground_editor()
{
	dh -= 28
	
	// Texture picker
	if (background_ground_tex.ready)
	{
		var textures = array_create(e_block_sheet.amount)
		for (var sheet = 0; sheet < e_block_sheet.static_amount; sheet++)
		{
			textures[sheet] = background_ground_tex.block_sheet_texture[sheet]
			if (textures[sheet] = null)
				textures[sheet] = mc_res.block_sheet_texture[sheet]
		}
		var anitextures = background_ground_tex.block_sheet_texture[e_block_sheet.ANIMATED]
		if (anitextures = null)
			anitextures = mc_res.block_sheet_texture[e_block_sheet.ANIMATED]
		if (anitextures != null)
			textures[e_block_sheet.ANIMATED] = anitextures[block_texture_get_frame(true)]
		var slotlists = array_create(e_block_sheet.amount)
		for (var sheet = 0; sheet < e_block_sheet.static_amount; sheet++)
			slotlists[sheet] = mc_assets.block_texture_list[sheet]
		slotlists[e_block_sheet.ANIMATED] = mc_assets.block_texture_ani_list
		var slots = array_create(e_block_sheet.amount)
		for (var sheet = 0; sheet < e_block_sheet.amount; sheet++)
			slots[sheet] = ds_list_size(slotlists[sheet])

		draw_texture_picker(background_ground_slot, textures, slots, minecraft_block_sheet_size, dx, dy, dw, dh, tab.ground_scroll, action_background_ground_slot, slotlists, background_ground_tex)
		
		if (content_mouseon)
			window_scroll_focus = string(tab.ground_scroll)
	}
}
