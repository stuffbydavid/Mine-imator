/// tab_ground_editor()

// Texture picker
if (background_ground_tex.ready)
{
	draw_label(text_get("groundeditorground") + ":", dx, dy)
	draw_texture_picker(background_ground_slot, background_ground_tex.block_sheet_texture,
						dx, dy + 22, dw, dh - 64, ds_list_size(mc_assets.block_texture_list), block_sheet_width, block_sheet_height, tab.ground_scroll, action_background_ground_slot,
						background_ground_tex.block_sheet_ani_texture, ds_list_size(mc_assets.block_texture_ani_list), block_sheet_ani_width, block_sheet_ani_height, background_ground_tex)
}

// OK
dy += dh - 32
if (draw_button_normal("groundeditorok", dx + floor(dw / 2) - 50, dy, 100, 32))
	tab_close(tab)
