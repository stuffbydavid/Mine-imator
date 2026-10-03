function tab_properties_resources_edit()
{
	if (res_edit.type = e_res_type.SCHEMATIC)
	{
		tab_control_checkbox()
		draw_checkbox("resources/scenery_randomize", dx, dy, res_edit.scenery_randomize, action_res_scenery_randomize, "resources/scenery_randomize_help")
		tab_next()
	}
	
	if (res_edit.type = e_res_type.PACK)
	{
		var showprojectpack = (res_edit != mc_res);
		for (var i = 0; !showprojectpack && i < ds_list_size(res_list.display_list); i++)
		{
			var res = res_list.display_list[|i];
			if (res != mc_res && res.type = e_res_type.PACK)
			{
				showprojectpack = true
				break
			}
		}

		if (showprojectpack)
		{
			tab_control_switch()
			draw_switch("resources/pack/project", dx, dy, project_pack = res_edit, action_res_project_pack)
			tab_next()
		}

		content_capwid = text_caption_width("resources/pack/image", "resourcespackimagecharacter", "resources/pack/image/color_map", "resources/pack/image/particles")
		
		tab_control_menu()
		draw_button_menu("resources/pack/image", e_menu.LIST, dx, dy, dw, 24, preview_edit.pack_image, text_get("resources/pack/" + preview_edit.pack_image), action_res_preview_pack_image)
		tab_next()

		switch (preview_edit.pack_image)
		{
			case "model_textures":
			{
				tab_control_menu()
				draw_button_menu("resources/pack/material", e_menu.LIST, dx, dy, dw, 24, preview_edit.pack_image_material, text_get("resources/pack/material/" + preview_edit.pack_image_material), action_res_preview_pack_image_material)
				tab_next()
				
				tab_control_menu()
				draw_button_menu("resources/pack/image/model_texture", e_menu.LIST, dx, dy, dw, 24, preview_edit.pack_model_texture, preview_edit.pack_model_texture, action_res_preview_pack_model_texture)
				tab_next()
				break
			}
			
			case "item_sheet":
			{
				tab_control_menu()
				draw_button_menu("resources/pack/material", e_menu.LIST, dx, dy, dw, 24, preview_edit.pack_image_material, text_get("resources/pack/material/" + preview_edit.pack_image_material), action_res_preview_pack_image_material)
				tab_next()

				tab_control_menu()
				draw_button_menu("resources/pack/image/item_sheet_size", e_menu.LIST, dx, dy, dw, 24, preview_edit.pack_item_sheet_size, text_get("resources/pack/image/item_sheet_size_" + string(item_size * (preview_edit.pack_item_sheet_size + 1))), action_res_preview_pack_item_sheet_size)
				tab_next()
				break
			}
			
			case "block_sheet":
			{
				tab_control_menu()
				draw_button_menu("resources/pack/material", e_menu.LIST, dx, dy, dw, 24, preview_edit.pack_image_material, text_get("resources/pack/material/" + preview_edit.pack_image_material), action_res_preview_pack_image_material)
				tab_next()
				
				tab_control_togglebutton()
				togglebutton_add("resources/pack/image/block_sheet_static", null, 0, !preview_edit.pack_block_sheet_ani, action_res_preview_pack_block_sheet_ani)
				togglebutton_add("resources/pack/image/block_sheet_animated", null, 1, preview_edit.pack_block_sheet_ani, action_res_preview_pack_block_sheet_ani)
				draw_togglebutton("resources/pack/image/block_sheet", dx, dy)
				tab_next()

				if (!preview_edit.pack_block_sheet_ani)
				{
					tab_control(24)
					draw_button_menu("resources/pack/image/block_sheet_size", e_menu.LIST_SEAMLESS, dx, dy, dw, 24, preview_edit.pack_block_sheet_size, text_get("resources/pack/image/block_sheet_size_" + string(block_size_list[preview_edit.pack_block_sheet_size])), action_res_preview_pack_block_sheet_size)
					tab_next()
				}
				break
			}
			
			case "color_map":
			{
				tab_control_togglebutton()
				togglebutton_add("resources/pack/image/colormap_grass", null, 0, preview_edit.pack_colormap = 0, action_res_preview_pack_colormap)
				togglebutton_add("resources/pack/image/colormap_foliage", null, 1, preview_edit.pack_colormap = 1, action_res_preview_pack_colormap)
				togglebutton_add("resources/pack/image/colormap_dry_foliage", null, 2, preview_edit.pack_colormap = 2, action_res_preview_pack_colormap)
				draw_togglebutton("resources/pack/image/color_map", dx, dy)
				tab_next()
				break
			}
			
			case "particle_sheet":
			{
				tab_control_togglebutton()
				togglebutton_add("resources/pack/image/particles_image_1", null, 0, preview_edit.pack_particles = 0, action_res_preview_pack_particles)
				togglebutton_add("resources/pack/image/particles_image_2", null, 1, preview_edit.pack_particles = 1, action_res_preview_pack_particles)
				draw_togglebutton("resources/pack/image/particles", dx, dy)
				tab_next()
				break
			}
			
			case "moon_texture":
			{
				tab_control_menu()
				draw_button_menu("resources/pack/moon_phase", e_menu.LIST, dx, dy, dw, 24, preview_edit.pack_moon_phase, text_get("resources/pack/moon_phase/" + string(preview_edit.pack_moon_phase + 1)), action_res_preview_pack_moon_phase)
				tab_next()
				break
			}
		}
	}
	else if (res_edit.type = e_res_type.ITEM_SHEET)
	{
		// Size
		axis_edit = X
		textfield_group_add("resources/item_sheet_size_columns", res_edit.item_sheet_size[X], minecraft_item_sheet_size[e_item_sheet.SIZE16][X], action_res_item_sheet_size, axis_edit, tab.resources.tbx_item_sheet_width, null, 1, 1, no_limit)
		axis_edit = Y
		textfield_group_add("resources/item_sheet_size_rows", res_edit.item_sheet_size[Y], minecraft_item_sheet_size[e_item_sheet.SIZE16][Y], action_res_item_sheet_size, axis_edit, tab.resources.tbx_item_sheet_height, null, 1, 1, no_limit)
		
		tab_control_textfield_group(true)
		draw_textfield_group("resources/item_sheet_size_grid", dx, dy, dw, 0.1, 1, no_limit, 1, true)
		tab_next()
	}
	else if (res_edit.scenery_structure)
	{
		if (res_edit.scenery_palette_size > 0)
		{
			tab_control_menu()
			draw_button_menu("resources/scenery_structure_palette", e_menu.LIST, dx, dy, dw, 24, res_edit.scenery_palette, text_get("resources/scenery_structure_palette_number", res_edit.scenery_palette + 1), action_res_scenery_palette)
			tab_next()
		}
		
		var busy, focus;
		busy = window_busy
		focus = window_focus
		
		tab_control_meter()
		draw_meter("resources/scenery_structure_integrity", dx, dy, dw, round(res_edit.scenery_integrity * 100), 0, 100, 100, 1, tab.resources.tbx_scenery_integrity, action_res_scenery_integrity)
		tab_next()
		
		// Auto-update for user's convenience
		if ((focus = string(tab.resources.tbx_scenery_integrity) && window_focus = "") ||
			(window_busy = "" && (busy = "resources/scenery_structure_integrity" || busy = "resources/scenery_structure_integrity/input/drag")))
		{
			with (res_edit)
				res_load()
		}
		
		tab_control_checkbox()
		draw_checkbox("resources/scenery_structure_integrity_invert", dx, dy, res_edit.scenery_integrity_invert, action_res_scenery_integrity_invert)
		tab_next()
	}
	
	// Material texture format
	if ((res_edit.type = e_res_type.BLOCK_SHEET || res_edit.type = e_res_type.DOWNLOADED_SKIN || res_edit.type = e_res_type.ITEM_SHEET || res_edit.type = e_res_type.PACK
		 || res_edit.type = e_res_type.PARTICLE_SHEET || res_edit.type = e_res_type.SKIN || res_edit.type = e_res_type.TEXTURE || res_edit.type = e_res_type.MODEL)
		 && res_edit != mc_res && setting_advanced_mode && project_render_material_maps)
	{
		tab_control_togglebutton()
		togglebutton_add("resources/material_format_labpbr", null, e_material.FORMAT_LABPBR, res_edit.material_format = e_material.FORMAT_LABPBR, action_res_material_format)
		togglebutton_add("resources/material_format_seus", null, e_material.FORMAT_SEUS, res_edit.material_format = e_material.FORMAT_SEUS, action_res_material_format)
		draw_togglebutton("resources/material_format", dx, dy)
		tab_next()
	}
	
	if (res_edit.filename != "") // Filename
	{
		var wid;
		content_capwid = text_caption_width("resources/file_name")
		
		// Model
		tab_control(24)
		
		draw_set_font(font_label)
		wid = string_width(text_get("resources/file_name") + ":")
		
		tip_wrap = false
		tip_set(string_remove_newline(project_folder + "/" + res_edit.filename), dx, dy, dw - wid, 24)
		tip_wrap = true
		
		draw_label(text_get("resources/file_name") + ":", dx, dy + 14, fa_left, fa_middle, c_text_secondary, a_text_secondary)
		draw_label(string_limit(string_remove_newline(res_edit.filename), dw - wid - 32), dx + wid + 8, dy + 14, fa_left, fa_middle, c_text_main, a_text_main, font_value)
		
		// Open in external program
		if (draw_button_icon("resources/file_name_open", dx + dw - 24, dy, 24, 24, false, icons.EXTERNAL, null, res_edit.type = e_res_type.SCHEMATIC || res_edit.type = e_res_type.FROM_WORLD, "tooltip/resource/open"))
			open_url(project_folder + "/" + res_edit.filename)
		
		tab_next()
	}
}
