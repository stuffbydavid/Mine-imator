/// bench_draw()

function bench_draw()
{
	if (bench_show_ani_type = "" && bench_show_ani = 0)
		return 0
	
	var func, ani;
	var sdx, sdy, ymax;
	
	// Animate
	func = ""
	if (bench_show_ani_type = "show")
	{
		bench_show_ani = min(1, bench_show_ani + 0.1 * delta)
		if (bench_show_ani = 1)
			bench_show_ani_type = ""
		func = "easeoutcirc"
	}
	else if (bench_show_ani_type = "hide")
	{
		bench_show_ani = max(0, bench_show_ani - 0.1 * delta)
		if (bench_show_ani = 0)
			bench_show_ani_type = ""
		func = "easeincirc"
	}
	
	if (bench_show_ani = 0)
	{
		bench_settings.height = 0
		bench_settings.height_goal = bench_height
		return 0
	}
	else
		bench_settings.height = bench_settings.height_goal;//(bench_settings.height_goal - bench_settings.height) / max(1, 3 / delta)
	
	if (window_busy = "bench")
		window_busy = ""
	
	ani = ease(func, bench_show_ani)
	content_x = bench_settings.posx + (8 - (8 * ani))
	content_y = bench_settings.posy
	content_width = 534
	content_height = bench_settings.height
	content_mouseon = !popup_mouseon
	
	dx = content_x
	dy = content_y
	dw = content_width
	dh = content_height
	
	// Hide bench
	if (!app_mouse_box(content_x, content_y, content_width, content_height) && mouse_left_pressed && window_busy = "") 
	{
		bench_show_ani_type = "hide"
		window_focus = ""
		
		app_mouse_clear()
	}
	
	draw_set_alpha(ani)
	draw_dropshadow(content_x, content_y, content_width, content_height, c_black, 1)
	draw_box(content_x, content_y, content_width, content_height, false, c_level_top, 1)
	draw_outline(content_x, content_y, content_width, content_height, 1, c_border, a_border, true)
	
	scissor_start(content_x - 4, content_y - 4, content_width + 8, content_height + 8)
	
	// Draw workbench
	sdx = dx
	sdy = dy
	
	dy += 8
	
	// Left, asset types
	var types, divides, lefth, skipasset;
	types = 13
	divides = 4
	lefth = (types * 32) + (divides * 9)
	for (var i = 0; i < ds_list_size(bench_type_list.item); i++)
	{
		skipasset = false
		
		if (!setting_advanced_mode)
		{
			if (bench_type_list.item[|i].name = "typemodel" || bench_type_list.item[|i].name = "typebackground" || bench_type_list.item[|i].name = "typepath" ||
				bench_type_list.item[|i].name = "typepathpoint" || bench_type_list.item[|i].name = "typejoint")
				skipasset = true
		}
		
		if (!skipasset)
		{
			list_item_draw(bench_type_list.item[|i], dx, dy, 192, 32, (bench_settings.type = bench_type_list.item[|i].value), 0, 5)
			dy += 32
		}
		
		if (i = 2 || i = 6 || i = 8 || (i = 13 && !skipasset))
		{
			draw_divide(dx + 5, dy + 4, 184)
			dy += 9
		}
	}
	dy += 8
	
	ymax = dy
	
	dy = sdy + 12
	dx += 192 + 12
	dw = (content_width - 192) - 24
	
	bench_draw_settings(dx, dy, dw, dh)
	
	ymax = max(dy, ymax)
	dy = ymax
	
	draw_divide_vertical(sdx + 193, sdy, bench_settings.height)
	bench_settings.height_goal = dy - sdy
	
	scissor_done()
	draw_set_alpha(1)
	
	if (window_busy = "" && bench_show_ani_type != "hide")
		window_busy = "bench"
}
