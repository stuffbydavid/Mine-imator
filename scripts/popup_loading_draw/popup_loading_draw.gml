/// popup_loading_draw()

if (popup.load_object && popup.load_script)
	with (popup.load_object)
		script_execute(app.popup.load_script)

dx += 8
dy += 8
dw -= 16
dh -= 16

dy += 8
draw_label(popup.text, dx, dy, fa_left, fa_center, c_text_secondary, a_text_secondary, font_value)
draw_label(text_get("exportstagedone", string(popup.progress * 100)), dx + dw, dy, fa_right, fa_center, c_text_secondary, a_text_secondary, font_value)
dy += 16

draw_box(dx, dy, dw, 8, false, c_border, a_border)
draw_box(dx, dy, dw * popup.progress, 8, false, c_accent, 1)

dy += 16
