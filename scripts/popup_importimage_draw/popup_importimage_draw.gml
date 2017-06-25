/// popup_importimage_draw()

// Info
draw_label(text_get("importimageinfo") + ":", dx, dy)
dy += 32

// Type
draw_radiobutton("importimageskin", dx, dy, "skin", popup.type = "skin", action_toolbar_importimage_type)
dy += 24
draw_radiobutton("importimageitemsheet", dx, dy, "itemsheet", popup.type = "itemsheet", action_toolbar_importimage_type)
dy += 24
draw_radiobutton("importimageblocksheet", dx, dy, "blocksheet", popup.type = "blocksheet", action_toolbar_importimage_type)
dy += 24
draw_radiobutton("importimageparticlesheet", dx, dy, "particlesheet", popup.type = "particlesheet", action_toolbar_importimage_type)
dy += 24
draw_radiobutton("importimagetexture", dx, dy, "texture", popup.type = "texture", action_toolbar_importimage_type)
dy += 24

// OK
dw = 100
dh = 32
dx = content_x + content_width / 2 - dw - 4
dy = content_y + content_height - 32
if (draw_button_normal("importimageok", dx, dy, dw, 32))
{
	if (popup.type = "itemsheet")
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
