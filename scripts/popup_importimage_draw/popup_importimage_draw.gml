/// popup_importimage_draw()

function popup_importimage_draw()
{
	// Info
	draw_label(text_get("importimagetype") + ":", dx, dy + 14, fa_left, fa_bottom, c_text_secondary, a_text_secondary, font_label)
	dy += 28
	
	tab_control(28)
	draw_radiobutton("importimageskin", dx, dy, e_res_type.SKIN, popup.type = e_res_type.SKIN, action_toolbar_importimage_type)
	tab_next()
	
	tab_control(28)
	draw_radiobutton("importimageitemsheet", dx, dy, e_res_type.ITEM_SHEET, popup.type = e_res_type.ITEM_SHEET, action_toolbar_importimage_type)
	tab_next()
	
	tab_control(28)
	draw_radiobutton("importimageblocksheet", dx, dy, e_res_type.BLOCK_SHEET, popup.type = e_res_type.BLOCK_SHEET, action_toolbar_importimage_type)
	tab_next()
	
	tab_control(28)
	draw_radiobutton("importimageparticlesheet", dx, dy, e_res_type.PARTICLE_SHEET, popup.type = e_res_type.PARTICLE_SHEET, action_toolbar_importimage_type)
	tab_next()
	
	tab_control(28)
	draw_radiobutton("importimagetexture", dx, dy, e_res_type.TEXTURE, popup.type = e_res_type.TEXTURE, action_toolbar_importimage_type)
	tab_next()
	
	// Ok
	tab_control_button_label()
	if (draw_button_label("importimageok", dx + dw, dy, null, null, e_button.PRIMARY, null, e_anchor.RIGHT))
	{
		if (popup.type = e_res_type.ITEM_SHEET)
			popup_importitemsheet_show(popup.filename, null)
		else
		{
			action_res_image_load(popup.filename, popup.type)
			popup_close()
		}
	}
	tab_next()
}
