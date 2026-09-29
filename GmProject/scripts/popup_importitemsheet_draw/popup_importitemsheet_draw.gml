function popup_importitemsheet_draw()
{
	// Preview
	var previewsize, previewx, previewy, previewwid, previewhei;
	var boxx, texwid, texhei, scale;
	previewsize = 256
	boxx = floor((content_x - (dx - content_x)) + content_width - previewsize)
	texwid = texture_width(popup_current.texture)
	texhei = texture_height(popup_current.texture)
	scale = max(texwid / previewsize, texhei / previewsize)
	previewwid = texwid / scale
	previewhei = texhei / scale
	previewx = boxx + ((previewsize / 2) - (previewwid / 2))
	previewy = dy
	
	tab_control(previewhei)
	draw_box(boxx, previewy, previewsize, previewhei, false, c_level_bottom, 1)
	draw_texture(popup_current.texture, previewx, previewy, 1 / scale, 1 / scale)
	
	if (popup_current.is_sheet)
	{
		var prevalpha = draw_get_alpha();
		draw_set_alpha(prevalpha * .35)
		
		// Grid
		for (var i = 1; i < popup_current.sheet_size[X]; i++)
			draw_line_color(previewx + (i / popup_current.sheet_size[X]) * previewwid, (previewy - 1), previewx + (i / popup_current.sheet_size[X]) * previewwid, previewy + previewhei - 1, c_text_main, c_text_main)
		for (var i = 1; i < popup_current.sheet_size[Y]; i++)
			draw_line_color((previewx - 1), previewy + (i / popup_current.sheet_size[Y]) * previewhei, previewx + previewwid - 1, previewy + (i / popup_current.sheet_size[Y]) * previewhei, c_text_main, c_text_main)
	
		draw_set_alpha(prevalpha)
	}
	tab_next()
	
	// Is sheet
	tab_control_switch()
	draw_switch("importitemsheetissheet", dx, dy, popup_current.is_sheet, action_toolbar_importitemsheet_is_sheet)
	tab_next()
	
	if (popup_current.is_sheet)
	{
		draw_set_font(font_label)
		
		// Size
		axis_edit = X
		textfield_group_add("importitemsheetcolumns", popup_current.sheet_size[X], popup_current.sheet_size_def[X], action_toolbar_importitemsheet_sheet_size, axis_edit, popup_current.tbx_sheet_width, null, 1, 1, no_limit)
		axis_edit = Y
		textfield_group_add("importitemsheetrows", popup_current.sheet_size[Y], popup_current.sheet_size_def[Y], action_toolbar_importitemsheet_sheet_size, axis_edit, popup_current.tbx_sheet_height, null, 1, 1, no_limit)
		
		tab_control_textfield_group(true)
		draw_textfield_group("importitemsheetgrid", dx, dy, dw, .1, 1, no_limit, 1, true)
		tab_next()
	}
	
	// Create
	tab_control_button_label()
	if (draw_button_label("importitemsheetok", dx + dw, dy, null, null, e_button.PRIMARY, null, e_anchor.RIGHT))
	{
		if (popup_current.value_script != null)
			script_execute(popup_current.value_script, e_option.IMPORT_ITEM_SHEET_DONE)
		else
			action_res_image_load(popup_current.filename, e_res_type.ITEM_SHEET)
		
		popup_close()
	}
	tab_next()
}
