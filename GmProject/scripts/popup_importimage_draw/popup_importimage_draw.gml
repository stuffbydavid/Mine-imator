function popup_importimage_draw()
{
	// Preview
	var boxsize, boxx, boxy;
	var texwid, texhei, previewx, previewy;
	var previewwid, previewhei, scale;
	boxsize = 256
	boxx = floor((content_x - (dx - content_x)) + content_width - boxsize)
	boxy = dy
	texwid = texture_width(popup_current.texture)
	texhei = texture_height(popup_current.texture)
	scale = max(texwid / boxsize, texhei / boxsize)
	previewwid = texwid / scale
	previewhei = texhei / scale
	previewx = boxx + ((boxsize / 2) - (previewwid / 2))
	previewy = boxy + ((boxsize / 2) - (previewhei / 2))
	
	draw_box(boxx, boxy, boxsize, boxsize, false, c_level_middle, 1)
	draw_box(previewx, previewy, previewwid, previewhei, false, c_level_bottom, 1)
	draw_texture(popup_current.texture, previewx, previewy, 1 / scale, 1 / scale)
	
	if (popup_current.type = e_res_type.ITEM_SHEET && popup_current.is_sheet)
	{
		var prevalpha = draw_get_alpha();
		draw_set_alpha(prevalpha * .35)
			
		// Sheet grid
		for (var i = 1; i < popup_current.sheet_size[X]; i++)
			draw_line_color(previewx + (i / popup_current.sheet_size[X]) * previewwid, (previewy - 1), previewx + (i / popup_current.sheet_size[X]) * previewwid, previewy + previewhei - 1, c_text_main, c_text_main)
		for (var i = 1; i < popup_current.sheet_size[Y]; i++)
			draw_line_color((previewx - 1), previewy + (i / popup_current.sheet_size[Y]) * previewhei, previewx + previewwid - 1, previewy + (i / popup_current.sheet_size[Y]) * previewhei, c_text_main, c_text_main)
			
		draw_set_alpha(prevalpha)
	}
	
	// Info
	draw_label(text_get("import_image/type") + ":", dx, dy + 14, fa_left, fa_bottom, c_text_secondary, a_text_secondary, font_label)
	dy += 28
	
	tab_control_checkbox()
	draw_radiobutton("import_image/skin", dx, dy, e_res_type.SKIN, popup_current.type = e_res_type.SKIN, action_toolbar_importimage_type)
	tab_next()
	
	tab_control_checkbox()
	draw_radiobutton("import_image/item_sheet", dx, dy, e_res_type.ITEM_SHEET, popup_current.type = e_res_type.ITEM_SHEET, action_toolbar_importimage_type)
	tab_next()
	
	tab_control_checkbox()
	draw_radiobutton("import_image/block_sheet", dx, dy, e_res_type.BLOCK_SHEET, popup_current.type = e_res_type.BLOCK_SHEET, action_toolbar_importimage_type)
	tab_next()
	
	tab_control_checkbox()
	draw_radiobutton("import_image/particle_sheet", dx, dy, e_res_type.PARTICLE_SHEET, popup_current.type = e_res_type.PARTICLE_SHEET, action_toolbar_importimage_type)
	tab_next()
	
	tab_control_checkbox()
	draw_radiobutton("import_image/texture", dx, dy, e_res_type.TEXTURE, popup_current.type = e_res_type.TEXTURE, action_toolbar_importimage_type)
	tab_next()
	
	tab_control(setting_interface_compact ? 100 : 80)
	tab_next(false)
	
	if (popup_current.type = e_res_type.ITEM_SHEET)
	{
		// Is sheet
		tab_control_switch()
		draw_switch("import_image/is_sheet", dx, dy, popup_current.is_sheet, action_toolbar_importimage_is_sheet)
		tab_next()
		
		if (popup_current.is_sheet)
		{
			draw_set_font(font_label)
			
			// Size
			axis_edit = X
			textfield_group_add("import_image/columns", popup_current.sheet_size[X], popup_current.sheet_size_def[X], action_toolbar_importimage_sheet_size, axis_edit, popup_current.tbx_sheet_width, null, 1, 1, no_limit)
			axis_edit = Y
			textfield_group_add("import_image/rows", popup_current.sheet_size[Y], popup_current.sheet_size_def[Y], action_toolbar_importimage_sheet_size, axis_edit, popup_current.tbx_sheet_height, null, 1, 1, no_limit)
			
			tab_control_textfield_group(true)
			draw_textfield_group("import_image/grid", dx, dy, dw, .1, 1, no_limit, 1, true)
			tab_next()
		}
	}
	
	if (ds_list_size(popup_current.filenames) > 1)
		draw_checkbox("import_image/do_all", dx, dy, popup_current.do_all, action_toolbar_importimage_do_all)
	
	// Create
	tab_control_button_label()
	if (draw_button_label("import_image/ok", dx + dw, dy, null, null, e_button.PRIMARY, null, e_anchor.RIGHT))
	{
		if (popup_current.type = e_res_type.ITEM_SHEET)
		{
			if (popup_current.do_all)
			{
				for (var i = 0; i < ds_list_size(popup_current.filenames); i++)
				{
					if (popup_current.value_script != null)
						script_execute(popup_current.value_script, e_option.IMPORT_ITEM_SHEET_DONE)
					else
						action_res_image_load(popup_current.filenames[|i], e_res_type.ITEM_SHEET)
				}
				ds_list_clear(popup_current.filenames)
			}
			else
			{
				if (popup_current.value_script != null)
					script_execute(popup_current.value_script, e_option.IMPORT_ITEM_SHEET_DONE)
				else
					action_res_image_load(popup_current.filename, e_res_type.ITEM_SHEET)
			}
		}
		else
		{
			if (popup_current.do_all)
			{
				for (var i = 0; i < ds_list_size(popup_current.filenames); i++)
					action_res_image_load(popup_current.filenames[|i], popup_current.type)
				ds_list_clear(popup_current.filenames)
			}
			else
				action_res_image_load(popup_current.filename, popup_current.type)
		}
		
		if (ds_list_size(popup_current.filenames) > 1)
		{
			ds_list_delete(popup_current.filenames, 0)
			popup_importimage_show(popup_current.filenames[|0])
			show_debug_message("New popup")
		}
		else
		{
			ds_list_clear(popup_current.filenames)
			popup_close()
		}
	}
	tab_next()
}
