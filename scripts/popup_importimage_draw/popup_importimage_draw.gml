/// popup_importimage_draw()

draw_label(text_get("importimageinfo") + ":", dx, dy)
dy += 32

draw_radiobutton("importimageskin", dx, dy, "skin", popup_importimage.type = "skin", action_toolbar_importimage_type)
dy += 24
draw_radiobutton("importimageitemsheet", dx, dy, "itemsheet", popup_importimage.type = "itemsheet", action_toolbar_importimage_type)
dy += 24
draw_radiobutton("importimageblocksheet", dx, dy, "blocksheet", popup_importimage.type = "blocksheet", action_toolbar_importimage_type)
dy += 24
draw_radiobutton("importimageparticlesheet", dx, dy, "particlesheet", popup_importimage.type = "particlesheet", action_toolbar_importimage_type)
dy += 24
draw_radiobutton("importimagetexture", dx, dy, "texture", popup_importimage.type = "texture", action_toolbar_importimage_type)
dy += 24

// OK
dw = 100
dh = 32
dx = content_x + content_width / 2 - dw - 4
dy = content_y + content_height - 32
if (draw_button_normal("importimageok", dx, dy, dw, 32))
{
	action_res_image_load(popup_importimage.type, popup_importimage.filename)
	popup_close()
}

// Cancel
dx = content_x + content_width / 2 + 4
if (draw_button_normal("importimagecancel", dx, dy, dw, 32))
	popup_close()
