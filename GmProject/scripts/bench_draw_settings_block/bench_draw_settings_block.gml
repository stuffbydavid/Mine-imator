function bench_draw_settings_block()
{
	bench_create_name = "bench/build"
	bench_create_icon = icons.BLOCK
	bench_create_button = e_bench_button.START_BUILDING
	
	bench_edit_hidden = false
	bench_edit_name = "bench/create"
	bench_edit_icon = icons.ASSET_ADD
	bench_edit_button = e_bench_button.CREATE

	draw_set_font(font_label)

	content_capwid = text_caption_width("bench/block_tex", "bench/block_tex_material", "bench/block_tex_normal")

	var settingsh, pickerh, asset, states;
	asset = mc_assets.block_name_map[?bench_settings.block_name]
	states = bench_settings.block_state
	settingsh = 8 + minecraft_asset_get_state_settings_height(asset)
	settingsh += (ui_large_height + 8) * (1 + 2 * project_render_material_maps)
	settingsh = max(bench_settings_height_min, settingsh)
	pickerh = bench_get_list_height(settingsh)
	
	// Block picker
	draw_asset_picker(bench_settings.block_tex, bench_settings.block_picker, asset.name, states, dx, dy, dw, pickerh, text_get("bench/block"))
	dy += pickerh + 8
	
	// Block state settings
	dy += draw_state_settings(asset, states, bench_settings.block_picker, action_bench_block_state, dx, dy, dw)

	// Texture
	draw_button_menu("bench/block_tex", e_menu.LIST, dx, dy, dw, ui_large_height, bench_settings.block_tex, res_eval(bench_settings.block_tex).display_name, action_bench_block_tex, false, res_eval(bench_settings.block_tex).block_preview_texture, null, "", null, null, content_capwid)
	dy += (ui_large_height + 8)

	if (project_render_material_maps)
	{
		// Material texture
		draw_button_menu("bench/block_tex_material", e_menu.LIST, dx, dy, dw, ui_large_height, bench_settings.block_tex_material, res_eval(bench_settings.block_tex_material).display_name, action_bench_block_tex_material, false, res_eval(bench_settings.block_tex_material).block_preview_texture, null, "", null, null, content_capwid)
		dy += (ui_large_height + 8)

		// Normal texture
		draw_button_menu("bench/block_tex_normal", e_menu.LIST, dx, dy, dw, ui_large_height, bench_settings.block_tex_normal, res_eval(bench_settings.block_tex_normal).display_name, action_bench_block_tex_normal, false, res_eval(bench_settings.block_tex_normal).block_preview_texture, null, "", null, null, content_capwid)
		dy += (ui_large_height + 8)
	}

	window_scroll_focus = string(bench_settings.block_picker.scroll)
}
