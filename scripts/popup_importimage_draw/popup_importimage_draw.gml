/// popup_importimage_draw()

// Info
draw_label(text_get("importimageinfo") + ":", dx, dy)
dy += 32

// Type
draw_radiobutton("importimageskin", dx, dy, e_res_type.SKIN, popup.type = e_res_type.SKIN, action_toolbar_importimage_type)
dy += 24
draw_radiobutton("importimageitemsheet", dx, dy, e_res_type.ITEM_SHEET, popup.type = e_res_type.ITEM_SHEET, action_toolbar_importimage_type)
dy += 24
draw_radiobutton("importimageblocksheet", dx, dy, e_res_type.BLOCK_SHEET, popup.type = e_res_type.BLOCK_SHEET, action_toolbar_importimage_type)
dy += 24
draw_radiobutton("importimageparticlesheet", dx, dy, e_res_type.PARTICLE_SHEET, popup.type = e_res_type.PARTICLE_SHEET, action_toolbar_importimage_type)
dy += 24
draw_radiobutton("importimagetexture", dx, dy, e_res_type.TEXTURE, popup.type = e_res_type.TEXTURE, action_toolbar_importimage_type)
dy += 24

// OK
dw = 100
dh = 32
dx = content_x + content_width / 2 - dw - 4
dy = content_y + content_height - 32
if (draw_button_normal("importimageok", dx, dy, dw, 32))
{
	if (popup.type = e_res_type.ITEM_SHEET)
		popup_importitemsheet_show(popup.filename, null)
	else
	{
		action_res_image_load(popup.filename, popup.type)
		popup_close()
	}
}

// Cancel
dx = content_x + content_width / 2 + 4
if (draw_button_normal("importimagecancel", dx, dy, dw, 32))
	popup_close()
