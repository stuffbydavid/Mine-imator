/// menu_settings_draw()

// Animation
if (settings_menu_ani_type = "hide") //Hide
{
	settings_menu_ani -= 0.08 * delta
	if (settings_menu_ani <= 0)
	{
		settings_menu_ani = 0
		settings_menu_name = ""
		list_destroy(settings_menu_list)
		return 0
	}
}
else if (settings_menu_ani_type = "show") //Show
{
	settings_menu_ani += 0.08 * delta
	if (settings_menu_ani >= 1)
	{
		settings_menu_ani = 1
		settings_menu_ani_type = ""
	}
}

if (settings_menu_name = "")
	return 0

var settingsmenuease = ease(((settings_menu_ani_type = "show") ? "easeoutexpo" : "easeinexpo"), settings_menu_ani);

content_x = settings_menu_x - (ceil(settings_menu_w/2) * settings_menu_primary)
content_y = settings_menu_y + ((16 * settingsmenuease) * settings_menu_primary)
content_width = settings_menu_w
content_height = (settings_menu_script ? settings_menu_h : (28 * settings_menu_amount))
content_mouseon = app_mouse_box_busy(content_x, content_y, content_width, content_height, "settingsmenu")

if (window_busy = "settingsmenu")
	window_busy = ""

draw_set_alpha(settingsmenuease)

draw_dropshadow(content_x, content_y, content_width, content_height, c_black, settingsmenuease)
draw_outline(content_x, content_y, content_width, content_height, 1, c_border, a_border * settingsmenuease)

draw_box(content_x, content_y, content_width, content_height, false, c_background, 1)

if (settings_menu_script)
{
	script_execute(settings_menu_script)
}
else
{
	var itemx, itemy;
	itemx = content_x
	itemy = content_y

	for (var i = 0; i < settings_menu_amount; i++)
	{
		list_item_draw(settings_menu_list.item[|i], itemx, itemy, content_width, 28, false, 4)
		itemy += 28
	}
}

// Draw arrow
if (settings_menu_primary)
{
	draw_image(spr_tooltip_arrow, 0, settings_menu_x, content_y, 1, 1, c_background, settingsmenuease)

	// Highlight arrow with top item
	if (settings_menu_amount > 0 && settings_menu_list.item[|0].hover)
	{
		if (mouse_left)
			draw_image(spr_tooltip_arrow, 0, settings_menu_x, content_y, 1, 1, c_accent_overlay, a_accent_overlay * settingsmenuease)
		else
			draw_image(spr_tooltip_arrow, 0, settings_menu_x, content_y, 1, 1, c_overlay, a_overlay * settingsmenuease)
	}

	draw_image(spr_tooltip_arrow, 1, settings_menu_x, content_y, 1, 1, c_border, a_border * settingsmenuease)
}

draw_set_alpha(1)

// Check click
if (settings_menu_script)
{
	if (mouse_left_released && !app_mouse_box(settings_menu_x, settings_menu_y, settings_menu_w, settings_menu_h) && !context_menu_mouseon)
	{
		settings_menu_ani = 1
		settings_menu_ani_type = "hide"
		window_busy = settings_menu_busy_prev
	}
}
else
{
	if (mouse_left_released)
	{
		settings_menu_ani = 1
		settings_menu_ani_type = "hide"
		window_busy = settings_menu_busy_prev
	}
}

if (window_busy = "" && settings_menu_ani_type != "hide")
	window_busy = "settingsmenu"
