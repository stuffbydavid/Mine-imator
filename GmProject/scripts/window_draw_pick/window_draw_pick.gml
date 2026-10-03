function window_draw_pick()
{
	if (window_busy != "pick_depth" || !window_mouse_is_active(window_get_current()))
		return 0

	if (mouse_left_pressed || mouse_right_pressed || mouse_middle_pressed || keyboard_check_pressed(vk_escape))
	{
		window_busy = ""
		mouse_cursor = cr_default
		window_set_cursor(cr_default)
		app_mouse_clear()
		return 0
	}

	mouse_cursor = cr_none
	window_set_cursor(cr_none)
	
	draw_set_alpha(1)
	draw_image(spr_icons, icons.PICKER, mouse_x, mouse_y, 1, 1, c_text_main, a_text_main)
}
