/// bench_draw()

function bench_draw()
{
	if (bench_show_ani_type = "" && bench_show_ani = 0)
		return 0
	
	var func, ani, benchbusy, benchmouseon;
	var sdx, sdy, ymax;
	
	// Animate
	func = ""
	if (bench_show_ani_type = "show")
	{
		bench_show_ani = test_reduced_motion(1, min(1, bench_show_ani + 0.1 * delta))
		if (bench_show_ani = 1)
			bench_show_ani_type = ""
		func = "easeoutcirc"
	}
	else if (bench_show_ani_type = "hide")
	{
		bench_show_ani = test_reduced_motion(0, max(0, bench_show_ani - 0.1 * delta))
		if (bench_show_ani = 0)
			bench_show_ani_type = ""
		func = "easeincirc"
	}
	
	if (bench_show_ani = 0)
	{
		if (window_busy = "bench" || window_busy = "benchresizewidth" || window_busy = "benchresizeheight" || window_busy = "benchresizecorner")
			window_busy = ""
		
		bench_settings.height = 0
		bench_settings.height_goal = bench_settings.height_min + bench_height_add
		return 0
	}
	else
		bench_settings.height = min(bench_settings.height_goal, max(0, window_height - bench_settings.posy - 32))
	
	if (window_busy = "bench")
		window_busy = ""
	
	ani = ease(func, bench_show_ani)
	content_x = bench_settings.posx - (8 - (8 * ani))
	content_y = bench_settings.posy
	content_width = bench_width
	content_height = bench_settings.height
	content_mouseon = !popup_mouseon
	
	dx = content_x
	dy = content_y
	dw = content_width
	dh = content_height

	benchbusy = window_busy
	benchmouseon = place_build && benchbusy = place_busy && app_mouse_box(content_x, content_y, content_width, content_height, place_busy)
	if (benchmouseon)
	{
		place_content_mouseon = "bench"
		window_busy = ""
		if (mouse_left_pressed)
			app_stop_place(false, false, false)
	}
	
	// Resize bench corner
	var mousecorner = content_mouseon && app_mouse_box(content_x + content_width - 8, content_y + content_height - 8, 8, 8);
	if (window_busy = "benchresizecorner")
	{
		mouse_cursor = cr_size_nwse
		bench_width = clamp(bench_resize_width + mouse_x - mouse_click_x, bench_min_width, bench_max_width)
		bench_height_add = clamp(bench_resize_height + mouse_y - mouse_click_y, bench_settings.height_min, max(bench_settings.height_min, window_height - content_y - 40)) - bench_settings.height_min
		if (!mouse_left)
		{
			window_busy = ""
			app_mouse_clear()
		}
	}
	else if (window_busy = "" && mousecorner)
	{
		mouse_cursor = cr_size_nwse
		if (mouse_left_pressed)
		{
			window_busy = "benchresizecorner"
			bench_resize_width = bench_width
			bench_resize_height = bench_settings.height
		}
	}

	// Resize bench width
	if (window_busy = "benchresizewidth")
	{
		mouse_cursor = cr_size_we
		bench_width = clamp(bench_resize_width + mouse_x - mouse_click_x, bench_min_width, bench_max_width)
		if (!mouse_left)
		{
			window_busy = ""
			app_mouse_clear()
		}
	}
	else if (window_busy = "" && content_mouseon && !mousecorner && app_mouse_box(content_x + content_width - 8, content_y, 8, content_height))
	{
		mouse_cursor = cr_size_we
		if (mouse_left_pressed)
		{
			window_busy = "benchresizewidth"
			bench_resize_width = bench_width
		}
	}

	// Resize bench height
	if (window_busy = "benchresizeheight")
	{
		mouse_cursor = cr_size_ns
		bench_height_add = clamp(bench_resize_height + mouse_y - mouse_click_y, bench_settings.height_min, max(bench_settings.height_min, window_height - content_y - 40)) - bench_settings.height_min
		if (!mouse_left)
		{
			window_busy = ""
			app_mouse_clear()
		}
	}
	else if (window_busy = "" && content_mouseon && !mousecorner && app_mouse_box(content_x, content_y + content_height - 6, content_width, 6))
	{
		mouse_cursor = cr_size_ns
		if (mouse_left_pressed)
		{
			window_busy = "benchresizeheight"
			bench_resize_height = bench_settings.height
		}
	}

	// Hide bench
	if (!app_mouse_box(content_x, content_y, content_width, content_height) && mouse_left_pressed && window_busy = "") 
	{
		if (bench_tab = e_bench.SOUND && bench_settings.sound_list_current.source = "music" && audio_exists(bench_settings.music_play_index) && audio_is_playing(bench_settings.music_play_index))
			bench_music_mode = true

		bench_sound_stop()
		bench_show_ani_type = "hide"
		window_focus = ""
		
		app_mouse_clear()
	}
	
	draw_set_alpha(ani)
	draw_dropshadow(content_x, content_y, content_width, content_height, c_black, 1)
	draw_box(content_x, content_y, content_width, content_height, false, c_level_top, 1)
	draw_outline(content_x, content_y, content_width, content_height, 1, c_border, a_border, true)
	
	//clip_begin(content_x - 4, content_y - 4, content_width + 8, content_height + 8)
	
	// Draw workbench
	sdx = dx
	sdy = dy
	
	dy += 8
	
	// Left, asset types
	var types, divides, lefth, skipasset;
	types = 13
	divides = 4
	lefth = (types * 32) + (divides * 9)
	for (var i = 0; i < ds_list_size(bench_tab_list.item); i++)
	{
		var item = bench_tab_list.item[|i]
		skipasset = false
		
		// Advanced mode check
		if (!setting_advanced_mode && array_contains(bench_advanced_tabs, item.value))
			skipasset = true
		
		if (!skipasset)
		{
			list_item_draw(item, dx, dy, 192, window_compact ? 28 : 32, bench_tab = item.value, 0, 5)
			dy += (window_compact ? 28 : 32)
		}
		
		// Separator check
		if (item.value = e_bench.MODEL_PART || item.value = e_bench.SPECIAL_BLOCK || item.value = e_bench.TEXT)
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
	
	bench_settings.list_height = 0
	bench_settings.list_minimum_height = 0
	bench_draw_settings(dx, dy, dw, dh)
	if (window_scroll_focus != "" && window_focus = window_scroll_focus && window_focus != string(bench_settings.item_scroll))
		bench_settings.list_focus = window_focus
	
	var minimumheight, settingsheight, maximumheight;
	settingsheight = dy - sdy
	if (bench_settings.list_height > 0)
	{
		bench_settings.height_fixed[bench_tab] = settingsheight - bench_settings.list_height
		if (bench_settings.height_fixed_base[bench_tab] = 0)
			bench_settings.height_fixed_base[bench_tab] = bench_settings.height_fixed[bench_tab]
		settingsheight = bench_settings.height_fixed[bench_tab] + bench_settings.list_minimum_height
	}
	minimumheight = max(settingsheight, ymax - sdy)
	maximumheight = max(0, window_height - sdy - 32)
	bench_settings.height_min = min(minimumheight, maximumheight)
	ymax = max(dy, ymax)
	dy = ymax
	
	draw_divide_vertical(sdx + 193, sdy, bench_settings.height)
	bench_settings.height_goal = clamp(bench_settings.height_min + bench_height_add, bench_settings.height_min, maximumheight)
	
	//clip_end()
	draw_set_alpha(1)
	
	if (place_build && benchmouseon)
		window_busy = benchbusy
	else if (window_state = "" && window_busy = "" && bench_show_ani_type != "hide")
		window_busy = "bench"
}
