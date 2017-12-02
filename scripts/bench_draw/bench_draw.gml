/// bench_draw()

var func, padding;
var boxx, boxy, boxw, boxh;
var settingsx, settingsy, settingsw, settingsh;
var listx, listy, listw, listh;
var iconsize, dx, dy;
padding = 5

// Animate
func = ""
if (bench_show_ani_type = "show")
{
	bench_show_ani = min(1, bench_show_ani + 0.1 * delta)
	if (bench_show_ani = 1)
		bench_show_ani_type = ""
	func = test(toolbar_location = "top" || toolbar_location = "left", "easeincirc", "easeoutcirc")
}
else if (bench_show_ani_type = "hide")
{
	bench_show_ani = max(0, bench_show_ani - 0.1 * delta)
	if (bench_show_ani = 0)
		bench_show_ani_type = ""
	func = test(toolbar_location = "bottom" || toolbar_location = "right", "easeoutcirc", "easeincirc")
}

if (bench_show_ani = 0)
{
	bench_settings.type = ""
	bench_settings.width = 0
	bench_settings.height = 0
	bench_settings.width_goal = 0
	bench_settings.height_goal = bench_height
	return 0
}

if (window_busy = "bench")
	window_busy = ""
	
// Box
if (window_busy = "")
{
	bench_settings.width += (bench_settings.width_goal - bench_settings.width) / max(1, 3 / delta)
	bench_settings.height += (bench_settings.height_goal - bench_settings.height) / max(1, 3 / delta)
}
else
{
	bench_settings.width = bench_settings.width_goal
	bench_settings.height = bench_settings.height_goal
}

settingsw = round(bench_settings.width)
settingsh = round(bench_settings.height)
boxw = bench_width + settingsw
boxh = max(bench_height, settingsh)

switch (toolbar_location)
{
	case "top":
		boxx = 5
		boxy = toolbar_size - boxh * ease(func, 1 - bench_show_ani)
		listx = boxx + padding
		listy = boxy
		listw = boxw - settingsw - padding * 2
		listh = boxh - padding
		break
		
	case "bottom":
		boxx = 5
		boxy = window_height - toolbar_size - boxh * ease(func, bench_show_ani)
		listx = boxx + padding
		listy = boxy + padding
		listw = boxw - settingsw - padding * 2
		listh = boxh - padding
		break
		
	case "left":
		boxx = toolbar_size - boxw * ease(func, 1 - bench_show_ani)
		boxy = 5
		listx = boxx
		listy = boxy + padding
		listw = boxw - settingsw - padding
		listh = boxh - padding * 2
		break
		
	case "right":
		boxx = window_width - toolbar_size - boxw * ease(func, bench_show_ani)
		boxy = 5
		listx = boxx + padding + settingsw
		listy = boxy + padding
		listw = boxw - settingsw - padding
		listh = boxh - padding * 2
		break
}

draw_drop_shadow(boxx, boxy, boxw, boxh)
draw_box(boxx, boxy, boxw, boxh, false, setting_color_interface, 1)

// List
draw_box(listx, listy, listw, listh, false, setting_color_background, 1)

iconsize = 80
dx = floor(listx)
dy = floor(listy)
if (toolbar_location = "bottom")
	dy = listy + listh - iconsize * 4

for (var l = 0; l < ds_list_size(bench_type_list); l++)
{
	var type, sel;
	type = bench_type_list[|l]
	sel = (bench_settings.type = type)
	
	if (sel)
		draw_box(dx, dy, iconsize, iconsize, false, setting_color_highlight, 1)
	draw_image(spr_icons_bench, l, dx + iconsize / 2, dy + iconsize / 2, 1, 1, test(sel, setting_color_highlight_text, setting_color_text), 1)
	
	if (bench_show_ani = 1)
		tip_set(text_get("benchtype" + tl_type_name_list[|type] + "tip"), dx, dy, iconsize, iconsize)
			   
	if (app_mouse_box(dx, dy, iconsize, iconsize) && bench_show_ani_type = "")
	{
		mouse_cursor = cr_handpoint
		if (mouse_left_pressed)
		{
			if (sel)
			{
				action_bench_create()
				bench_show_ani_type = "hide"
			}
			else
				bench_click(type)
		}
	}

	dx += iconsize
	if (dx + iconsize > listx + listw)
	{
		dx = listx
		dy += iconsize
	}
}

// Hide bench
if (!app_mouse_box(boxx, boxy, boxw, boxh) && mouse_left_pressed && window_busy = "") 
{
	bench_show_ani_type = "hide"
	app_mouse_clear()
}

// Settings
if (bench_settings.type != "")
{
	var mouseonresizehor, mouseonresizever;
	
	if (toolbar_location = "right")
	{
		mouseonresizehor = app_mouse_box(boxx, boxy, padding, boxh)
		settingsx = boxx
	}
	else 
	{
		mouseonresizehor = app_mouse_box(boxx + boxw - padding, boxy, padding, boxh)
		settingsx = boxx + bench_width
	}
	settingsy = boxy
	
	if (toolbar_location = "bottom")
		mouseonresizever = app_mouse_box(boxx, boxy, boxw, padding)
	else
		mouseonresizever = app_mouse_box(boxx, boxy + boxh - padding, boxw, padding)
		
	if (mouseonresizehor && mouseonresizever) // Both
	{
		if (toolbar_location = "right" || toolbar_location = "bottom")
			mouse_cursor = cr_size_nesw
		else
			mouse_cursor = cr_size_nwse
		
		if (mouse_left_pressed)
		{
			window_busy = "benchresizeboth"
			bench_settings.resize_width = bench_settings.width_custom
			bench_settings.resize_height = bench_settings.height_custom
		}
	}
	else if (mouseonresizehor) // Horizontal
	{
		mouse_cursor = cr_size_we
		if (mouse_left_pressed)
		{
			window_busy = "benchresizehor"
			bench_settings.resize_width = bench_settings.width_custom
		}
	}
	else if (mouseonresizever) // Vertical
	{
		mouse_cursor = cr_size_ns
		if (mouse_left_pressed)
		{
			window_busy = "benchresizever"
			bench_settings.resize_height = bench_settings.height_custom
		}
	}
	
	bench_draw_settings(settingsx, settingsy, settingsw, settingsh)
}

// Resize
if (window_busy = "benchresizehor" || window_busy = "benchresizeboth")
{
	mouse_cursor = cr_size_we
	bench_settings.width_custom = max(0, bench_settings.resize_width + negate(toolbar_location = "right") * (mouse_x - mouse_click_x))
	if (!mouse_left)
		window_busy = ""
}

if (window_busy = "benchresizever" || window_busy = "benchresizeboth")
{
	mouse_cursor = cr_size_ns
	bench_settings.height_custom = max(0, bench_settings.resize_height + negate(toolbar_location = "bottom") * (mouse_y - mouse_click_y))
	if (!mouse_left)
		window_busy = ""
}

if (window_busy = "benchresizeboth")
{
	if (toolbar_location = "right" || toolbar_location = "bottom")
		mouse_cursor = cr_size_nesw
	else
		mouse_cursor = cr_size_nwse
}

if (window_busy = "" && bench_show_ani_type != "hide")
	window_busy = "bench"
