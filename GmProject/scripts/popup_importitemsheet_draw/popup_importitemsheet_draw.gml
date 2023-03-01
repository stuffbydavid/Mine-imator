/// popup_importitemsheet_draw()

function popup_importitemsheet_draw()
{
	// Preview
	var previewsize, previewx, previewy, previewwid, previewhei;
	var texwid, texhei, scale;
	previewsize = 256
	previewx = floor(content_x + content_width / 2 - previewsize / 2)
	previewy = floor(dy + previewsize / 2 - previewsize / 2)
	texwid = texture_width(popup.texture)
	texhei = texture_height(popup.texture)
	
	// Too big for preview, scale down
	if (texhei > texwid)
	{
		scale = previewsize / texhei
		previewx += (previewsize - scale * texwid) / 2
	}
	else
	{
		scale = previewsize / texwid
		previewy = dy
	}
	
	previewwid = texwid * scale
	previewhei = texhei * scale
	
	tab_control(previewhei)
	draw_box(previewx, previewy, previewwid, previewhei, false, c_level_bottom, 1)
	draw_texture(popup.texture, previewx, previewy, scale, scale)
	
	if (popup.is_sheet)
	{
		var prevalpha = draw_get_alpha();
		draw_set_alpha(prevalpha * .35)
		
		// Grid
		for (var i = 1; i < popup.sheet_size[X]; i++)
			draw_line_color(previewx + (i / popup.sheet_size[X]) * previewwid, (previewy - 1), previewx + (i / popup.sheet_size[X]) * previewwid, previewy + previewhei - 1, c_text_main, c_text_main)
		for (var i = 1; i < popup.sheet_size[Y]; i++)
			draw_line_color((previewx - 1), previewy + (i / popup.sheet_size[Y]) * previewhei, previewx + previewwid - 1, previewy + (i / popup.sheet_size[Y]) * previewhei, c_text_main, c_text_main)
	
		draw_set_alpha(prevalpha)
	}
	tab_next()
	
	// Is sheet
	tab_control_switch()
	draw_switch("importitemsheetissheet", dx, dy, popup.is_sheet, action_toolbar_importitemsheet_is_sheet)
	tab_next()
	
	if (popup.is_sheet)
	{
		draw_set_font(font_label)
		
		// Size
		axis_edit = X
		tab_control(28)
		draw_dragger("importitemsheetrows", dx, dy, dragger_width, popup.sheet_size[X], 1 / 10, 1, no_limit, popup.sheet_size_def[X], 1, popup.tbx_sheet_width, action_toolbar_importitemsheet_sheet_size)
		tab_next()
		
		axis_edit = Y
		tab_control(28)
		draw_dragger("importitemsheetcolumns", dx, dy, dragger_width, popup.sheet_size[Y], 1 / 10, 1, no_limit, popup.sheet_size_def[Y], 1, popup.tbx_sheet_height, action_toolbar_importitemsheet_sheet_size)
		tab_next()
	}
	
	// Create
	tab_control_button_label()
	if (draw_button_label("importimageok", dx + dw, dy, null, null, e_button.PRIMARY, null, e_anchor.RIGHT))
	{
		if (popup.value_script != null)
			script_execute(popup.value_script, e_option.IMPORT_ITEM_SHEET_DONE)
		else
			action_res_image_load(popup.filename, e_res_type.ITEM_SHEET)
		
		popup_close()
	}
	tab_next()
}
