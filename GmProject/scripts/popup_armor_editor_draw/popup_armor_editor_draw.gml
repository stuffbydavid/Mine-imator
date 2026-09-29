function popup_armor_editor_draw()
{
	popup_current.preview.select = popup_current.armor_edit
	popup_current.preview.last_select = popup_current.armor_edit
	popup_current.preview.update = true
	preview_draw(popup_current.preview, dx, dy, 200, dh - (dy - content_y + 44))
	
	// Settings
	dx += 216
	dw = 310
	
	content_capwid = 128
	
	popup_armor_editor_draw_piece("helmet", 0)
	
	draw_divide(dx, dy, dw)
	dy += 8
	
	popup_armor_editor_draw_piece("chestplate", 4)
	
	draw_divide(dx, dy, dw)
	dy += 8
	
	popup_armor_editor_draw_piece("leggings", 8)
	
	draw_divide(dx, dy, dw)
	dy += 8
	
	popup_armor_editor_draw_piece("boots", 12)
	
	dy += 12
	tab_control_button_label()
	if (draw_button_label("armoreditorok", content_x + content_width / 2, dy, 100, null, e_button.PRIMARY, null, e_anchor.CENTER))
		popup_close()
	tab_next()
}
