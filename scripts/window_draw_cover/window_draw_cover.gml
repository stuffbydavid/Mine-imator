/// window_draw_cover()

if (popup && popup.block)
	window_cover = min(window_cover + 0.05 * delta, 1)
else
	window_cover = max(window_cover - 0.05 * delta, 0)
	
draw_box(0, 0, window_width, window_height, false, c_black, window_cover * 0.33)
