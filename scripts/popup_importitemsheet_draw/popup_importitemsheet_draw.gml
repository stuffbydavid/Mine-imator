/// popup_importitemsheet_draw()

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
	previewy += (previewsize - scale * texhei) / 2
}

previewwid = texwid * scale
previewhei = texhei * scale

draw_box(previewx, previewy, previewwid, previewhei, false, setting_color_background, 1)
draw_texture(popup.texture, previewx, previewy, scale, scale)

if (popup.is_sheet)
{
	// Grid
	for (var i = 0; i < popup.sheet_size[X]; i++)
		draw_line_color(previewx + (i / popup.sheet_size[X]) * previewwid, previewy, previewx + (i / popup.sheet_size[X]) * previewwid, previewy + previewhei, c_gray, c_gray)
	for (var i = 0; i < popup.sheet_size[Y]; i++)
		draw_line_color(previewx, previewy + (i / popup.sheet_size[Y]) * previewhei, previewx + previewwid, previewy + (i / popup.sheet_size[Y]) * previewhei, c_gray, c_gray)
}

dy += previewsize + 24

// Is sheet
draw_checkbox("importitemsheetissheet", dx, dy, popup.is_sheet, action_toolbar_importitemsheet_is_sheet)
dy += 32

if (popup.is_sheet)
{
	// Info
	draw_label(text_get("importitemsheetinfo") + ":", dx, dy)
	dy += 24

	// Size
	var capwid = text_caption_width("importitemsheetwidth", "importitemsheetheight");
	axis_edit = X
	draw_dragger("importitemsheetwidth", dx, dy, dw / 2, popup.sheet_size[X], 1 / 10, 1, no_limit, popup.sheet_size_def[X], 1, popup.tbx_sheet_width, action_toolbar_importitemsheet_sheet_size, capwid)
	dy += 24
	axis_edit = Y
	draw_dragger("importitemsheetheight", dx, dy, dw / 2, popup.sheet_size[Y], 1 / 10, 1, no_limit, popup.sheet_size_def[Y], 1, popup.tbx_sheet_height, action_toolbar_importitemsheet_sheet_size, capwid)
}

// OK
dw = 100
dh = 32
dx = content_x + content_width / 2 - dw - 4
dy = content_y + content_height - 32
if (draw_button_normal("importimageok", dx, dy, dw, 32))
{
	if (popup.value_script != null)
		script_execute(popup.value_script, e_option.IMPORT_ITEM_SHEET_DONE)
	else
		action_res_image_load(popup.filename, "itemsheet")
	popup_close()
}

// Cancel
dx = content_x + content_width / 2 + 4
if (draw_button_normal("importimagecancel", dx, dy, dw, 32))
	popup_close()
