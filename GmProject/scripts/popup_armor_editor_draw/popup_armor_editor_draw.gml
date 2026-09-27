/// popup_armor_editor_draw()

function popup_armor_editor_draw()
{
	popup.preview.select = popup.armor_edit
	popup.preview.last_select = popup.armor_edit
	popup.preview.update = true
	preview_draw(popup.preview, dx, dy, 200, dh - (dy - content_y + 44))
	
	// Settings
	dx += 216
	dw = 310
	
	var capwid = 128;
	
	popup_armor_editor_draw_piece("helmet", 0, capwid)
	
	draw_divide(dx, dy, dw)
	dy += 8
	
	popup_armor_editor_draw_piece("chestplate", 4, capwid)
	
	draw_divide(dx, dy, dw)
	dy += 8
	
	popup_armor_editor_draw_piece("leggings", 8, capwid)
	
	draw_divide(dx, dy, dw)
	dy += 8
	
	popup_armor_editor_draw_piece("boots", 12, capwid)
	
	dy += 12
	tab_control_button_label()
	if (draw_button_label("armoreditorok", content_x + content_width / 2, dy, 100, null, e_button.PRIMARY, null, e_anchor.CENTER))
		popup_close()
	tab_next()
}
