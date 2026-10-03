function bench_draw_settings_schematic()
{
	// Schematic
	tab_control(bench_list_height(bench_settings.schematic_list))
	sortlist_draw(bench_settings.schematic_list, dx, dy, dw, tab_control_h, bench_settings.schematic_selected, false, text_get("bench/schematic"))
	tab_next()
	dy -= 4

	// Schematics folder
	tab_control_togglebutton(2, 3)
	for (var i = 0; i < array_length(schematic_folders); i++)
	{
		var schematicfolder = schematic_folders[i];
		togglebutton_add("bench/schematic/" + string_replace_all(string_lower(schematicfolder), " ", "_"), null, schematicfolder, bench_schematic_folder = schematicfolder, action_bench_schematic_folder)
	}
	togglebutton_add("bench/schematic/project", null, "project", bench_schematic_folder = "project", action_bench_schematic_folder)
	draw_togglebutton("bench/schematic", dx, dy, true, false)
	dy += ui_large_height * 2 + 6

	// Import schematic
	tab_control(24)
	if (draw_button_icon("bench/schematic/import", dx, dy, 24, 24, false, icons.ASSET_ADD, null, false, "tooltip/schematic/import"))
		action_bench_schematic_import()

	// Export schematic
	var schematicselected, exportdisabled;
	schematicselected = bench_settings.schematic_selected
	exportdisabled = (schematicselected = null)
	
	if (!exportdisabled && !is_string(schematicselected))
		exportdisabled = (schematicselected.type = e_res_type.FROM_WORLD)
	
	if (draw_button_icon("bench/schematic/export", dx + 28, dy, 24, 24, false, icons.ASSET_EXPORT, null, exportdisabled, "tooltip/schematic/export"))
		action_bench_schematic_export()

	// Open folder
	if (draw_button_icon("bench/schematic/openfolder", dx + 56, dy, 24, 24, false, icons.FOLDER, null, false, "tooltip/schematic/open_folder"))
		action_bench_schematic_open_folder()

	// Reload folder
	if (draw_button_icon("bench/schematic/reload", dx + 84, dy, 24, 24, false, icons.REFRESH, null, false, "tooltip/schematic/reload_folder"))
		action_bench_schematic_folder(bench_schematic_folder)
	
	tab_next()

	// Texture
	content_capwid = text_caption_width("bench/block_tex", "bench/block_tex_material", "bench/block_tex_normal")
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

	bench_create_disabled = (bench_settings.scenery = null)
	
	if (content_mouseon)
		window_scroll_focus = string(bench_settings.schematic_list.scroll)
}
