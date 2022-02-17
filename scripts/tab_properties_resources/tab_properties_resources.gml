/// tab_properties_resources()

function tab_properties_resources()
{
	var capwid;
	
	// Preview selected resource
	tab_control(160)
	preview_draw(res_preview, dx, dy, dw, 160)
	tab_next()
	
	// List
	tab_control_sortlist(6)
	sortlist_draw(tab.resources.list, dx, dy, dw, tab_control_h, res_edit)
	tab_next()
	
	// Tools
	tab_control(24)
	
	if (draw_button_icon("resourcesnew", dx, dy, 24, 24, false, icons.ASSET_IMPORT, null, false, "tooltipresourcenew"))
		action_toolbar_import_asset()
	
	if (draw_button_icon("previewexport", dx + 28, dy, 24, 24, false, icons.ASSET_EXPORT, null, !res_edit, "tooltipresourcesave"))
		action_res_export()
	
	if (draw_button_icon("resourcesreload", dx + (28 * 2), dy, 24, 24, false, icons.RELOAD, null, (!res_edit || res_edit = mc_res), "tooltipresourcereload"))
		action_res_reload()
	
	if (draw_button_icon("resourcesreplace", dx + (28 * 3), dy, 24, 24, false, icons.FOLDER, null, (!res_edit || res_edit = mc_res), "tooltipresourcereplace"))
		action_res_replace()
	
	if (draw_button_icon("resourcesremove", dx + (28 * 4), dy, 24, 24, false, icons.DELETE, null, (!res_edit || res_edit = mc_res), "tooltipresourceremove"))
		action_res_remove()
	
	tab_next()
	
	if (res_edit = null)
		return 0
	
	if (res_edit.type = e_res_type.PACK)
	{
		capwid = text_caption_width("resourcespackimage", "resourcespackimagecharacter", "resourcespackimagecolormap", "resourcespackimageparticles")
		
		tab_control_menu()
		draw_button_menu("resourcespackimage", e_menu.LIST, dx, dy, dw, 24, res_preview.pack_image, text_get("resourcespack" + res_preview.pack_image), action_res_preview_pack_image, false)
		tab_next()
		
		switch (res_preview.pack_image)
		{
			case "modeltextures":
			{
				tab_control_menu()
				draw_button_menu("resourcespackmaterial", e_menu.LIST, dx, dy, dw, 24, res_preview.pack_image_material, text_get("resourcespackmaterial" + res_preview.pack_image_material), action_res_preview_pack_image_material, false)
				tab_next()
				
				tab_control_menu()
				draw_button_menu("resourcespackimagemodeltexture", e_menu.LIST, dx, dy, dw, 24, res_preview.pack_model_texture, res_preview.pack_model_texture, action_res_preview_pack_model_texture, false)
				tab_next()
				break
			}
			
			case "itemsheet":
			{
				tab_control_menu()
				draw_button_menu("resourcespackmaterial", e_menu.LIST, dx, dy, dw, 24, res_preview.pack_image_material, text_get("resourcespackmaterial" + res_preview.pack_image_material), action_res_preview_pack_image_material, false)
				tab_next()
				break
			}
			
			case "blocksheet":
			{
				tab_control_menu()
				draw_button_menu("resourcespackmaterial", e_menu.LIST, dx, dy, dw, 24, res_preview.pack_image_material, text_get("resourcespackmaterial" + res_preview.pack_image_material), action_res_preview_pack_image_material, false)
				tab_next()
				
				tab_control_togglebutton()
				togglebutton_add("resourcespackimageblocksheetstatic", null, 0, !res_preview.pack_block_sheet_ani, action_res_preview_pack_block_sheet_ani)
				togglebutton_add("resourcespackimageblocksheetanimated", null, 1, res_preview.pack_block_sheet_ani, action_res_preview_pack_block_sheet_ani)
				draw_togglebutton("resourcespackimageblocksheet", dx, dy)
				tab_next()
				break
			}
			
			case "colormap":
			{
				tab_control_togglebutton()
				togglebutton_add("resourcespackimagecolormapgrass", null, 0, res_preview.pack_colormap = 0, action_res_preview_pack_colormap)
				togglebutton_add("resourcespackimagecolormapfoliage", null, 1, res_preview.pack_colormap = 1, action_res_preview_pack_colormap)
				draw_togglebutton("resourcespackimagecolormap", dx, dy)
				tab_next()
				break
			}
			
			case "particlesheet":
			{
				tab_control_togglebutton()
				togglebutton_add("resourcespackimageparticlesimage1", null, 0, res_preview.pack_particles = 0, action_res_preview_pack_particles)
				togglebutton_add("resourcespackimageparticlesimage2", null, 1, res_preview.pack_particles = 1, action_res_preview_pack_particles)
				draw_togglebutton("resourcespackimageparticles", dx, dy)
				tab_next()
				break
			}
		}
	}
	else if (res_edit.type = e_res_type.ITEM_SHEET)
	{
		// Size
		axis_edit = X
		tab_control_dragger()
		draw_dragger("resourcesitemsheetsizerows", dx, dy, dragger_width, res_edit.item_sheet_size[X], 1 / 10, 1, no_limit, item_sheet_width, 1, tab.resources.tbx_item_sheet_width, action_res_item_sheet_size)
		tab_next()
		
		axis_edit = Y
		tab_control_dragger()
		draw_dragger("resourcesitemsheetsizecolumns", dx, dy, dragger_width, res_edit.item_sheet_size[Y], 1 / 10, 1, no_limit, item_sheet_height, 1, tab.resources.tbx_item_sheet_height, action_res_item_sheet_size)
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
		
		tab_control_meter()
		draw_meter("resourcesscenerystructureintegrity", dx, dy, dw, round(res_edit.scenery_integrity * 100), 64, 0, 100, 100, 1, tab.resources.tbx_scenery_integrity, action_res_scenery_integrity)
		tab_next()
		
		tab_control_switch()
		draw_switch("resourcesscenerystructureintegrityinvert", dx, dy, res_edit.scenery_integrity_invert, action_res_scenery_integrity_invert)
		tab_next()
	}
	
	// Material texture settings (Advanced mode only)
	if ((res_edit.type = e_res_type.BLOCK_SHEET || res_edit.type = e_res_type.DOWNLOADED_SKIN || res_edit.type = e_res_type.ITEM_SHEET || res_edit.type = e_res_type.PACK
		 || res_edit.type = e_res_type.PARTICLE_SHEET || res_edit.type = e_res_type.SKIN || res_edit.type = e_res_type.TEXTURE || res_edit.type = e_res_type.MODEL) && res_edit != mc_res && setting_advanced_mode && project_render_material_maps)
	{
		tab_control_switch()
		draw_switch("resourcesusesglossiness", dx, dy, res_edit.material_uses_glossiness, action_res_uses_glossiness, "resourcesusesglossinesstip")
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
		tip_set(string_remove_newline(project_folder + "\\" + res_edit.filename), dx, dy, dw - wid, 24)
		tip_wrap = true
		
		draw_label(text_get("resourcesfilename") + ":", dx, dy + 14, fa_left, fa_middle, c_text_secondary, a_text_secondary)
		draw_label(string_limit(string_remove_newline(res_edit.filename), dw - wid - 32), dx + wid + 8, dy + 14, fa_left, fa_middle, c_text_main, a_text_main, font_value)
		
		// Open in external program
		if (draw_button_icon("resourcesfilenameopen", dx + dw - 24, dy, 24, 24, false, icons.FOLDER, null, res_edit.type = e_res_type.SCENERY, "tooltipresourceopen"))
			open_url(project_folder + "\\" + res_edit.filename)
		
		tab_next()
	}
}
