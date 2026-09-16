function tab_properties_resources_edit()
{
	if (res_edit.type = e_res_type.SCHEMATIC)
	{
		tab_control_checkbox()
		draw_checkbox("resourcessceneryrandomize", dx, dy, res_edit.scenery_randomize, action_res_scenery_randomize, "resourcessceneryrandomizehelp")
		tab_next()
	}
	
	if (res_edit.type = e_res_type.PACK)
	{
		var showprojectpack, res;
		showprojectpack = (res_edit != mc_res)
		for (var i = 0; !showprojectpack && i < ds_list_size(res_list.display_list); i++)
		{
			res = res_list.display_list[|i]
			if (res != mc_res && res.type = e_res_type.PACK)
			{
				showprojectpack = true
				break
			}
		}

		if (showprojectpack)
		{
			tab_control_switch()
			draw_switch("resourcespackproject", dx, dy, project_pack = res_edit, action_res_project_pack)
			tab_next()
		}

		capwid = text_caption_width("resourcespackimage", "resourcespackimagecharacter", "resourcespackimagecolormap", "resourcespackimageparticles")
		
		tab_control_menu()
		draw_button_menu("resourcespackimage", e_menu.LIST, dx, dy, dw, 24, preview_edit.pack_image, text_get("resourcespack" + preview_edit.pack_image), action_res_preview_pack_image)
		tab_next()

		switch (preview_edit.pack_image)
		{
			case "modeltextures":
			{
				tab_control_menu()
				draw_button_menu("resourcespackmaterial", e_menu.LIST, dx, dy, dw, 24, preview_edit.pack_image_material, text_get("resourcespackmaterial" + preview_edit.pack_image_material), action_res_preview_pack_image_material)
				tab_next()
				
				tab_control_menu()
				draw_button_menu("resourcespackimagemodeltexture", e_menu.LIST, dx, dy, dw, 24, preview_edit.pack_model_texture, preview_edit.pack_model_texture, action_res_preview_pack_model_texture)
				tab_next()
				break
			}
			
			case "itemsheet":
			{
				tab_control_menu()
				draw_button_menu("resourcespackmaterial", e_menu.LIST, dx, dy, dw, 24, preview_edit.pack_image_material, text_get("resourcespackmaterial" + preview_edit.pack_image_material), action_res_preview_pack_image_material)
				tab_next()

				tab_control_menu()
				draw_button_menu("resourcespackimageitemsheetsize", e_menu.LIST, dx, dy, dw, 24, preview_edit.pack_item_sheet_size, text_get("resourcespackimageitemsheetsize" + string(item_size * (preview_edit.pack_item_sheet_size + 1))), action_res_preview_pack_item_sheet_size)
				tab_next()
				break
			}
			
			case "blocksheet":
			{
				tab_control_menu()
				draw_button_menu("resourcespackmaterial", e_menu.LIST, dx, dy, dw, 24, preview_edit.pack_image_material, text_get("resourcespackmaterial" + preview_edit.pack_image_material), action_res_preview_pack_image_material)
				tab_next()
				
				tab_control_togglebutton()
				togglebutton_add("resourcespackimageblocksheetstatic", null, 0, !preview_edit.pack_block_sheet_ani, action_res_preview_pack_block_sheet_ani)
				togglebutton_add("resourcespackimageblocksheetanimated", null, 1, preview_edit.pack_block_sheet_ani, action_res_preview_pack_block_sheet_ani)
				draw_togglebutton("resourcespackimageblocksheet", dx, dy)
				tab_next()

				if (!preview_edit.pack_block_sheet_ani)
				{
					tab_control(24)
					draw_button_menu("resourcespackimageblocksheetsize", e_menu.LIST_SEAMLESS, dx, dy, dw, 24, preview_edit.pack_block_sheet_size, text_get("resourcespackimageblocksheetsize" + string(block_size_list[preview_edit.pack_block_sheet_size])), action_res_preview_pack_block_sheet_size)
					tab_next()
				}
				break
			}
			
			case "colormap":
			{
				tab_control_togglebutton()
				togglebutton_add("resourcespackimagecolormapgrass", null, 0, preview_edit.pack_colormap = 0, action_res_preview_pack_colormap)
				togglebutton_add("resourcespackimagecolormapfoliage", null, 1, preview_edit.pack_colormap = 1, action_res_preview_pack_colormap)
				togglebutton_add("resourcespackimagecolormapdryfoliage", null, 2, preview_edit.pack_colormap = 2, action_res_preview_pack_colormap)
				draw_togglebutton("resourcespackimagecolormap", dx, dy)
				tab_next()
				break
			}
			
			case "particlesheet":
			{
				tab_control_togglebutton()
				togglebutton_add("resourcespackimageparticlesimage1", null, 0, preview_edit.pack_particles = 0, action_res_preview_pack_particles)
				togglebutton_add("resourcespackimageparticlesimage2", null, 1, preview_edit.pack_particles = 1, action_res_preview_pack_particles)
				draw_togglebutton("resourcespackimageparticles", dx, dy)
				tab_next()
				break
			}
			
			case "moontexture":
			{
				tab_control_menu()
				draw_button_menu("resourcespackmoonphase", e_menu.LIST, dx, dy, dw, 24, preview_edit.pack_moon_phase, text_get("resourcespackmoonphase" + string(preview_edit.pack_moon_phase + 1)), action_res_preview_pack_moon_phase)
				tab_next()
				break
			}
		}
	}
	else if (res_edit.type = e_res_type.ITEM_SHEET)
	{
		// Size
		axis_edit = X
		textfield_group_add("resourcesitemsheetsizecolumns", res_edit.item_sheet_size[X], minecraft_item_sheet_size[e_item_sheet.SIZE16][X], action_res_item_sheet_size, axis_edit, tab.resources.tbx_item_sheet_width, null, 1, 1, no_limit)
		axis_edit = Y
		textfield_group_add("resourcesitemsheetsizerows", res_edit.item_sheet_size[Y], minecraft_item_sheet_size[e_item_sheet.SIZE16][Y], action_res_item_sheet_size, axis_edit, tab.resources.tbx_item_sheet_height, null, 1, 1, no_limit)
		
		tab_control_textfield_group(true)
		draw_textfield_group("resourcesitemsheetsizegrid", dx, dy, dw, 0.1, 1, no_limit, 1, true)
		tab_next()
	}
	else if (res_edit.scenery_structure)
	{
		if (res_edit.scenery_palette_size > 0)
		{
			tab_control_menu()
			draw_button_menu("resourcesscenerystructurepalette", e_menu.LIST, dx, dy, dw, 24, res_edit.scenery_palette, text_get("resourcesscenerystructurepalettenumber", res_edit.scenery_palette + 1), action_res_scenery_palette)
			tab_next()
		}
		
		var busy = window_busy;
		var focus = window_focus;
		
		tab_control_meter()
		draw_meter("resourcesscenerystructureintegrity", dx, dy, dw, round(res_edit.scenery_integrity * 100), 0, 100, 100, 1, tab.resources.tbx_scenery_integrity, action_res_scenery_integrity)
		tab_next()
		
		// Auto-update for user's convenience
		if ((focus = string(tab.resources.tbx_scenery_integrity) && window_focus = "") || (window_busy = "" && (busy = "resourcesscenerystructureintegrity" || busy = "resourcesscenerystructureintegrityinputdrag")))
		{
			with (res_edit)
				res_load()
		}
		
		tab_control_checkbox()
		draw_checkbox("resourcesscenerystructureintegrityinvert", dx, dy, res_edit.scenery_integrity_invert, action_res_scenery_integrity_invert)
		tab_next()
	}
	
	// Material texture format
	if ((res_edit.type = e_res_type.BLOCK_SHEET || res_edit.type = e_res_type.DOWNLOADED_SKIN || res_edit.type = e_res_type.ITEM_SHEET || res_edit.type = e_res_type.PACK
		 || res_edit.type = e_res_type.PARTICLE_SHEET || res_edit.type = e_res_type.SKIN || res_edit.type = e_res_type.TEXTURE || res_edit.type = e_res_type.MODEL) && res_edit != mc_res && setting_advanced_mode && project_render_material_maps)
	{
		tab_control_togglebutton()
		togglebutton_add("resourcesmaterialformatlabpbr", null, e_material.FORMAT_LABPBR, res_edit.material_format = e_material.FORMAT_LABPBR, action_res_material_format)
		togglebutton_add("resourcesmaterialformatseus", null, e_material.FORMAT_SEUS, res_edit.material_format = e_material.FORMAT_SEUS, action_res_material_format)
		draw_togglebutton("resourcesmaterialformat", dx, dy)
		tab_next()
	}
	
	if (res_edit.filename != "") // Filename
	{
		var wid = text_max_width("resourcesfilenameopen") + 20;
		capwid = text_caption_width("resourcesfilename")
		
		// Model
		tab_control(24)
		
		draw_set_font(font_label)
		wid = string_width(text_get("resourcesfilename") + ":")
		
		tip_wrap = false
		tip_set(string_remove_newline(project_folder + "/" + res_edit.filename), dx, dy, dw - wid, 24)
		tip_wrap = true
		
		draw_label(text_get("resourcesfilename") + ":", dx, dy + 14, fa_left, fa_middle, c_text_secondary, a_text_secondary)
		draw_label(string_limit(string_remove_newline(res_edit.filename), dw - wid - 32), dx + wid + 8, dy + 14, fa_left, fa_middle, c_text_main, a_text_main, font_value)
		
		// Open in external program
		if (draw_button_icon("resourcesfilenameopen", dx + dw - 24, dy, 24, 24, false, icons.EXTERNAL, null, res_edit.type = e_res_type.SCHEMATIC || res_edit.type = e_res_type.FROM_WORLD, "tooltipresourceopen"))
			open_url(project_folder + "/" + res_edit.filename)
		
		tab_next()
	}
}
