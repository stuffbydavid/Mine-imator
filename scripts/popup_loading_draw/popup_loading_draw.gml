/// popup_loading_draw()

if (popup.load_object && popup.load_script)
	with (popup.load_object)
		script_execute(app.popup.load_script)

draw_loading_bar(content_x, content_y, content_width, content_height, popup.progress, popup.text)
