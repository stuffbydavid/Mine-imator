/// tab_ground_editor()

// Texture picker
if (background_ground_tex.ready)
{
	draw_texture_picker(background_ground_slot, background_ground_tex.block_sheet_texture,
						dx, dy, dw, dh - 58, ds_list_size(mc_assets.block_texture_list), block_sheet_width, block_sheet_height, tab.ground_scroll, action_background_ground_slot,
						background_ground_tex.block_sheet_ani_texture, ds_list_size(mc_assets.block_texture_ani_list), block_sheet_ani_width, block_sheet_ani_height, background_ground_tex)
	
	if (content_mouseon)
		window_scroll_focus = string(tab.ground_scroll)
}

dy += dh - (22 + 28)
if (draw_button_primary("groundeditordone", dx, dy, null, null, null, fa_center))
	tab_close(tab)
