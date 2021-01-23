/// tab_ground_editor()

dh -= (36 + 34)

// Texture picker
if (background_ground_tex.ready)
{
	draw_texture_picker(background_ground_slot, background_ground_tex.block_sheet_texture,
						dx, dy, dw, dh, ds_list_size(mc_assets.block_texture_list), block_sheet_width, block_sheet_height, tab.ground_scroll, action_background_ground_slot,
						background_ground_tex.block_sheet_ani_texture, ds_list_size(mc_assets.block_texture_ani_list), block_sheet_ani_width, block_sheet_ani_height, background_ground_tex)
	
	if (content_mouseon)
		window_scroll_focus = string(tab.ground_scroll)
}

dy += dh + 8
if (draw_button_label("groundeditordone", floor(dx + dw/2), dy, null, null, e_button.PRIMARY, null, e_anchor.CENTER))
	tab_close(tab)
