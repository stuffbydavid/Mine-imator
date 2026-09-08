/// tab_ground_editor()

function tab_ground_editor()
{
	dh -= 28
	
	// Texture picker
	if (background_ground_tex.ready)
	{
		draw_texture_picker(background_ground_slot, background_ground_tex.block_sheet_texture[e_block_sheet.STATIC16],
							dx, dy, dw, dh, ds_list_size(mc_assets.block_texture_list[e_block_sheet.STATIC16]), minecraft_block_sheet_size[e_block_sheet.STATIC16][X], minecraft_block_sheet_size[e_block_sheet.STATIC16][Y], tab.ground_scroll, action_background_ground_slot,
							background_ground_tex.block_sheet_texture[e_block_sheet.ANIMATED], ds_list_size(mc_assets.block_texture_ani_list), minecraft_block_sheet_size[e_block_sheet.ANIMATED][X], minecraft_block_sheet_size[e_block_sheet.ANIMATED][Y], background_ground_tex)
		
		if (content_mouseon)
			window_scroll_focus = string(tab.ground_scroll)
	}
}
