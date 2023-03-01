/// app_event_draw()

function app_event_draw()
{
	delta = clamp(delta_time / (1000000 / 60), 0.5, 1.5)
	
	draw_set_font(font_label)
	draw_set_color(c_text_main)
	
	window_draw()
}
