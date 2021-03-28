/// popup_loading_draw()

if (popup.load_object && popup.load_script)
	with (popup.load_object)
		script_execute(app.popup.load_script)

dx += 8
dy += 8
dw -= 16
dh -= 16

tab_control_loading()
draw_loading_bar(dx, dy, dw, 8, popup.progress, popup.text)
tab_next()
