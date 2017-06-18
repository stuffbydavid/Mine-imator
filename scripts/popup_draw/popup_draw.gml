/// popup_draw()

var boxx, boxy, boxw, boxh

// Animate
if (popup_ani_type = "show")
{
	popup_ani = min(1, popup_ani + 0.05 * delta)
	if (popup_ani = 1)
		popup_ani_type = ""
}
else if (popup_ani_type = "hide")
{
	popup_ani = max(0, popup_ani - 0.1 * delta)
	if (popup_ani = 0)
	{
		if (popup_switch_to)
		{
			popup = popup_switch_to
			popup_switch_to = null
			popup_ani_type = "show"
			window_busy = ""
		}
		else
		{
			window_busy = ""
			popup = null
			popup_ani_type = ""
			popup_switch_from = null
		}
	}
}

if (!popup)
{
	popup_mouseon = false
	return 0
}

if (window_busy = "popupmove")
	draw_set_alpha(0.5)

if (window_busy = "popup" + popup.name)
	window_busy = ""

// Box
boxw = popup.width
boxh = popup.height

boxx = popup.offset_x + window_width / 2 - boxw / 2
boxy = popup.offset_y + window_height / 2 - boxh / 2
boxy += ease("easeincirc", 1 - popup_ani) * (window_height - boxy)

boxx = floor(boxx)
boxy = floor(boxy)

popup_mouseon = app_mouse_box(boxx, boxy, boxw, boxh)

content_x = boxx
content_y = boxy
content_width = boxw
content_height = boxh
content_tab = null

draw_drop_shadow(boxx, boxy, boxw, boxh)
draw_box(boxx, boxy, boxw, boxh, false, setting_color_interface, 1)

// Caption
draw_set_font(setting_font_bold)
draw_label(string_limit(string_remove_newline(popup.caption), boxw - 20), boxx + 10, boxy + 5)
draw_set_font(setting_font)
draw_separator_horizontal(boxx + 10, boxy + 25, boxw - 20)

// Move
if (window_busy = "popupclick")
{
	if (mouse_move > 10)
	{
		popup_move_offset_x = popup.offset_x
		popup_move_offset_y = popup.offset_y
		window_busy = "popupmove"
	}
	else if (!mouse_left)
		window_busy = ""
}

if (window_busy = "popupmove")
{
	popup.offset_x = popup_move_offset_x + (mouse_x - mouse_click_x)
	popup.offset_y = popup_move_offset_y + (mouse_y - mouse_click_y)
	if (!mouse_left)
		window_busy = ""
}
else
{
	popup.offset_x = clamp(popup.offset_x, -(window_width - boxw) / 2, (window_width - boxw) / 2)
	popup.offset_y = clamp(popup.offset_y, -(window_height - boxh) / 2, (window_height - boxh) / 2)
}

// Draw contents
content_x = boxx + 30
content_y = boxy + 50
content_width = boxw - 60
content_height = boxh - 80
content_mouseon = app_mouse_box(content_x, content_y, content_width, content_height)

dx = content_x
dy = content_y
dw = content_width
dh = content_height
script_execute(popup.script)

if (popup_mouseon && mouse_cursor = cr_default && mouse_left_pressed)
	window_busy = "popupclick"

if (window_busy = "" && popup.block)
	window_busy = "popup" + popup.name

draw_set_alpha(1)
