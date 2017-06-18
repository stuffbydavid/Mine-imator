/// panel_draw(panel)
/// @arg panel

var panel;
var boxx, boxy, boxw, boxh, resizemouseon, padding;
var tabtitle, tabx, tabw, tabmaxw, tabsw, tabsh, tablistmouseon, tabmouseon;
var dx, dy;

panel = argument0

panel.glow = max(0, panel.glow - 0.05)
if (panel.size_real < 1 && panel.glow = 0)
	return 0

// Calculate box
if (panel = panel_left_top)
{
	boxx = panel_area_x
	boxy = panel_area_y
	boxw = panel.size_real
	boxh = panel_area_height
	content_direction = e_scroll.VERTICAL
	if (panel.glow > 0)
		draw_gradient(boxx, boxy, 100, boxh, c_yellow, panel.glow, 0, 0, panel.glow)
}
else if (panel = panel_right_top)
{
	boxx = panel_area_x + panel_area_width - panel.size_real
	boxy = panel_area_y
	boxw = panel.size_real
	boxh = panel_area_height
	content_direction = e_scroll.VERTICAL
	if (panel.glow > 0)
		draw_gradient(boxx + boxw - 100, boxy, 100, boxh, c_yellow, 0, panel.glow, panel.glow, 0)
}
else if (panel = panel_bottom)
{
	boxx = panel_area_x + panel_left_top.size_real
	boxy = panel_area_y + panel_area_height - panel.size_real
	boxw = panel_area_width - panel_left_top.size_real - panel_right_top.size_real
	boxh = panel.size_real
	content_direction = e_scroll.HORIZONTAL
	if (panel.glow > 0)
		draw_gradient(boxx, boxy + boxh - 100, boxw, 100, c_yellow, 0, 0, panel.glow, panel.glow)
}
else if (panel = panel_top)
{
	boxx = panel_area_x + panel_left_top.size_real
	boxy = panel_area_y
	boxw = panel_area_width - panel_left_top.size_real - panel_right_top.size_real
	boxh = panel.size_real
	content_direction = e_scroll.HORIZONTAL
	if (panel.glow > 0)
		draw_gradient(boxx, boxy, boxw, 100, c_yellow, panel.glow, panel.glow, 0, 0)
}
else if (panel = panel_left_bottom)
{
	boxx = panel_area_x + panel_left_top.size_real
	boxy = panel_area_y + panel_top.size_real
	boxw = panel.size_real
	boxh = panel_area_height - panel_top.size_real - panel_bottom.size_real
	content_direction = e_scroll.VERTICAL
	if (panel.glow > 0)
		draw_gradient(boxx, boxy, 100, boxh, c_yellow, panel.glow, 0, 0, panel.glow)
}
else if (panel = panel_right_bottom)
{
	boxx = panel_area_x + panel_area_width - panel_right_top.size_real - panel.size_real
	boxy = panel_area_y + panel_top.size_real
	boxw = panel.size_real
	boxh = panel_area_height - panel_top.size_real - panel_bottom.size_real
	content_direction = e_scroll.VERTICAL
	if (panel.glow > 0)
		draw_gradient(boxx + boxw - 100, boxy, 100, boxh, c_yellow, 0, panel.glow, panel.glow, 0)
}

if (boxw < 1 || boxh < 1)
	return 0
	
if (panel.tab_list_amount = 0)
	return 0

boxx = floor(boxx)
boxy = floor(boxy)
boxw = ceil(boxw)
boxh = ceil(boxh)

// Background
draw_box(boxx, boxy, boxw, boxh, false, setting_color_interface, 1)

// Content
tabsh = min(boxh, 28)
content_x = boxx
content_y = boxy + tabsh
content_width = boxw
content_height = boxh - tabsh
content_mouseon = (app_mouse_box(content_x, content_y, content_width, content_height) && !popup_mouseon)
content_tab = panel.tab_list[panel.tab_selected]
panel_draw_content()
content_y = boxy

// Tabs
tabsw = 0
tabmaxw = boxw
padding = 10
tablistmouseon = null
tabmouseon = false

for (var t = 0; t < panel.tab_list_amount; t++)
{
	var tab, sel;
	tab = panel.tab_list[t]
	sel = (panel.tab_selected = t)
	
	tabtitle[t] = tab_get_title(tab)
	
	if (sel)
		draw_set_font(setting_font_bold)
		
	tabw[t] = string_width(tabtitle[t]) + padding * 2
	
	if (sel)
		draw_set_font(setting_font)
		
	if (panel.tab_selected = t && tab.closeable)
		tabw[t] += 20
		
	tabw[t] = min(tabw[t], tabmaxw)
	tabsw += tabw[t]
}

if (content_tab = timeline)
{
	tabmaxw = timeline.list_width
	draw_box(boxx, boxy, tabmaxw, tabsh, false, setting_color_interface, 1)
}
else
	draw_box(boxx, boxy, tabmaxw, tabsh + 4, false, setting_color_interface, 1)
	
draw_box(boxx, boxy, tabmaxw, tabsh, false, setting_color_background, 1)

dx = boxx
dy = boxy
content_mouseon=!popup_mouseon

for (var t = 0; t < panel.tab_list_amount; t++)
{
	var tab, sel, dw, dh;
	tab = panel.tab_list[t]
	sel = (panel.tab_selected = t)
	
	tabx[t] = dx
	if (!sel)
		tabw[t] -= max(0, tabsw - tabmaxw) / (panel.tab_list_amount - 1)
		
	dw = tabw[t]
	dh = tabsh
	
	if (sel)
		draw_box(dx, dy, dw, dh, false, setting_color_interface, 1)
	
	tabtitle[t] = string_limit(tabtitle[t], dw - padding * 2-20 * (sel && tab.closeable))
	
	// Close button
	if (sel && tab.closeable)
	{
		if (draw_button_normal("tabclose", dx + dw - 18, dy + 8, 16, 16, e_button.NO_TEXT, false, false, true, icons.close))
		{
			tab_close(tab)
			return 0
		}
	}
	
	// Label
	if (sel)
		draw_set_font(setting_font_bold)
	draw_label(tabtitle[t], floor(dx + dw / 2) - 5*(sel && tab.closeable), dy + dh / 2, fa_center, fa_middle)
	if (sel)
		draw_set_font(setting_font)
	
	// Click
	if (app_mouse_box(dx, dy, dw, dh))
	{
		if (!sel)
		{
			tablistmouseon = t
			mouse_cursor = cr_handpoint
		}
		else
			tabmouseon = true
	}
	
	// List glow
	tab.glow = max(0, tab.glow - 0.05)
	if (window_busy = "tabmove")
	{
		window_busy = ""
		if (app_mouse_box(dx, dy, dw, dh))
		{
			tab.glow = min(1, tab.glow + 0.1 * delta)
			tab_move_mouseon_panel = panel
			tab_move_mouseon_position = t
		}
		window_busy = "tabmove"
	}
	
	if (tab.glow > 0)
		draw_box(dx, dy, dw, dh - 1, false, c_yellow, tab.glow * glow_alpha)
	
	dx += tabw[t]
}

panel.list_glow = max(0, panel.list_glow - 0.05 * delta)
if (tabmaxw > tabsw)
{
	// Moving?
	if (window_busy = "tabmove")
	{
		window_busy = ""
		if (app_mouse_box(boxx + tabsw, boxy, tabmaxw - tabsw, tabsh))
		{
			panel.list_glow = min(1, panel.list_glow + 0.1 * delta)
			tab_move_mouseon_panel = panel
			tab_move_mouseon_position = panel.tab_list_amount
		}
		window_busy = "tabmove"
	}
	
	// Glow for new tab
	if (panel.list_glow > 0)
		draw_box(boxx + tabsw, boxy, min(tab_move_width, tabmaxw - tabsw), tabsh, false, c_yellow, panel.list_glow * glow_alpha)
}

// Glow
if (content_tab.glow > 0)
	draw_box(boxx, boxy + tabsh, boxw, boxh - tabsh, false, c_yellow, content_tab.glow * glow_alpha)

// Border
resizemouseon = false
if (panel = panel_left_top || panel = panel_left_bottom)
{
	draw_gradient(boxx + boxw, boxy, shadow_size, boxh, c_black, shadow_alpha, 0, 0, shadow_alpha)
	if (app_mouse_box(boxx + boxw - 5, boxy, 5, boxh) && tablistmouseon = null && !popup_mouseon)
	{
		mouse_cursor = cr_size_we
		resizemouseon = true
	}
}
else if (panel = panel_right_top || panel = panel_right_bottom)
{
	draw_gradient(boxx - shadow_size, boxy, shadow_size, boxh, c_black, 0, shadow_alpha, shadow_alpha, 0)
	if (app_mouse_box(boxx, boxy, 5, boxh) && tablistmouseon = null && !popup_mouseon)
	{
		mouse_cursor = cr_size_we
		resizemouseon = true
	}
}
else if (panel = panel_bottom)
{
	draw_gradient(boxx, boxy - shadow_size, boxw, shadow_size, c_black, 0, 0, shadow_alpha, shadow_alpha)
	if (app_mouse_box(boxx, boxy, boxw, 5) && tablistmouseon = null && !popup_mouseon)
	{
		mouse_cursor = cr_size_ns
		resizemouseon = true
	}
}
else if (panel = panel_top)
{
	draw_gradient(boxx, boxy + boxh, boxw, shadow_size, c_black, shadow_alpha, shadow_alpha, 0, 0)
	if (app_mouse_box(boxx, boxy + boxh - 5, boxw, 5) && tablistmouseon = null && !popup_mouseon)
	{
		mouse_cursor = cr_size_ns
		resizemouseon = true
	}
}

// Resize
if (resizemouseon && mouse_left_pressed)
{
	window_busy = "panelresize"
	panel_resize = panel
	panel_resize_size = panel.size_real
}

// Move
if (tabmouseon && mouse_cursor = cr_default && mouse_left_pressed)
{
	window_busy = "tabclick"
	tab_move = content_tab
}

if (window_busy = "tabclick")
{
	if (tab_move = null) // Tab was closed
		window_busy = ""
	else if (tab_move = content_tab)
	{
		if (mouse_move > 10)
		{
			window_busy = "tabmove"
			tab_move_name = tabtitle[panel.tab_selected]
			tab_move_x = min(boxw - tabw[panel.tab_selected], tabx[panel.tab_selected] - boxx)
			tab_move_width = tabw[panel.tab_selected]
			tab_move_direction = content_direction
			tab_move_box_x = boxx - mouse_x
			tab_move_box_y = boxy - mouse_y
			tab_move_box_width = boxw
			tab_move_box_height = boxh
			panel_tab_list_remove(panel, panel.tab_list[panel.tab_selected])
		}
		else if (!mouse_left)
			window_busy = ""
	}
}

if (window_busy = "tabmove")
{
	window_busy = ""
	if (app_mouse_box(boxx, boxy + tabsh, boxw, boxh - tabsh))
	{
		tab_move_mouseon_panel = panel
		tab_move_mouseon_position = panel.tab_selected
		content_tab.glow = min(1, content_tab.glow + 0.1 * delta)
	}
	window_busy = "tabmove"
}

// Click tab list
if (tablistmouseon != null && mouse_left_pressed)
{
	panel.tab_selected = tablistmouseon
	window_busy = "tabclick"
	tab_move = panel.tab_list[tablistmouseon]
}
