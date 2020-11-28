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
if (panel = panel_map[?"bottom"])
{ 
	boxx = panel_area_x + panel_map[?"left"].size_real 
	boxy = panel_area_y + panel_area_height - panel.size_real 
	boxw = panel_area_width - panel_map[?"left"].size_real - panel_map[?"right"].size_real 
	boxh = panel.size_real 
	content_direction = e_scroll.HORIZONTAL 
	if (panel.glow > 0) 
		draw_gradient(boxx, boxy + boxh - 100, boxw, 100, c_accent, 0, 0, panel.glow * glow_alpha, panel.glow * glow_alpha) 
}
else if (panel = panel_map[?"top"]) 
{ 
	boxx = panel_area_x + panel_map[?"left"].size_real 
	boxy = panel_area_y 
	boxw = panel_area_width - panel_map[?"left"].size_real - panel_map[?"right"].size_real 
	boxh = panel.size_real 
	content_direction = e_scroll.HORIZONTAL 
	if (panel.glow > 0) 
		draw_gradient(boxx, boxy, boxw, 100, c_accent, panel.glow * glow_alpha, panel.glow * glow_alpha, 0, 0) 
}
else if (panel = panel_map[?"left"])
{
	boxx = panel_area_x
	boxy = panel_area_y + panel_map[?"top"].size_real 
	boxw = panel.size_real
	boxh = panel_area_height - panel_map[?"top"].size_real 
	content_direction = e_scroll.VERTICAL
	if (panel.glow > 0)
		draw_gradient(boxx, boxy, 100, boxh, c_accent, panel.glow * glow_alpha, 0, 0, panel.glow * glow_alpha)
}
else if (panel = panel_map[?"left_secondary"])
{
	boxx = panel_area_x + panel_map[?"left"].size_real
	boxy = panel_area_y + panel_map[?"top"].size_real 
	boxw = panel.size_real
	boxh = panel_area_height - panel_map[?"top"].size_real - panel_map[?"bottom"].size_real 
	content_direction = e_scroll.VERTICAL
	if (panel.glow > 0)
		draw_gradient(boxx, boxy, 100, boxh, c_accent, panel.glow * glow_alpha, 0, 0, panel.glow * glow_alpha)
}
else if (panel = panel_map[?"right"])
{
	boxx = panel_area_x + panel_area_width - panel.size_real
	boxy = panel_area_y + panel_map[?"top"].size_real 
	boxw = panel.size_real
	boxh = panel_area_height - panel_map[?"top"].size_real 
	content_direction = e_scroll.VERTICAL
	if (panel.glow > 0)
		draw_gradient(boxx + boxw - 100, boxy, 100, boxh, c_accent, 0, panel.glow * glow_alpha, panel.glow * glow_alpha, 0)
}
else if (panel = panel_map[?"right_secondary"])
{
	boxx = panel_area_x + panel_area_width - panel_map[?"right"].size_real - panel.size_real
	boxy = panel_area_y + panel_map[?"top"].size_real 
	boxw = panel.size_real
	boxh = panel_area_height - panel_map[?"top"].size_real - panel_map[?"bottom"].size_real 
	content_direction = e_scroll.VERTICAL
	if (panel.glow > 0)
		draw_gradient(boxx + boxw - 100, boxy, 100, boxh, c_accent, 0, panel.glow * glow_alpha, panel.glow * glow_alpha, 0)
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
draw_box(boxx, boxy, boxw, boxh, false, c_background, 1)

// Content
tabsh = min(boxh, 28)
content_tab = panel.tab_list[panel.tab_selected]
content_x = boxx
content_y = boxy + (tabsh * content_tab.movable)
content_width = boxw
content_height = boxh - (tabsh * content_tab.movable)
content_mouseon = (app_mouse_box(content_x, content_y, content_width, content_height) && !popup_mouseon && !snackbar_mouseon && !context_menu_mouseon)
panel_draw_content()
content_y = boxy

// Tabs
tabsw = 0
tabmaxw = boxw
padding = 10
tablistmouseon = null
tabmouseon = false

if (content_tab.movable)
{
	for (var t = 0; t < panel.tab_list_amount; t++)
	{
		var tab, sel;
		tab = panel.tab_list[t]
		sel = (panel.tab_selected = t)
	
		tabtitle[t] = tab_get_title(tab)
	
		draw_set_font(font_emphasis)
		tabw[t] = string_width(tabtitle[t]) + 16
	
		if (tab.closeable)
			tabw[t] += 26
	
		tabw[t] = min(tabw[t], tabmaxw)
		tabsw += tabw[t]
	}

	dx = boxx
	dy = boxy
	content_mouseon = !popup_mouseon && !snackbar_mouseon && !context_menu_mouseon

	// Tabs background
	draw_box(dx, dy, tabmaxw, tabsh, false, c_background_secondary, 1)

	draw_box(dx, dy + tabsh, tabmaxw, 1, false, c_border, a_border)

	for (var t = 0; t < panel.tab_list_amount; t++)
	{
		var tab, sel, dw, dh;
		tab = panel.tab_list[t]
		sel = (panel.tab_selected = t)
	
		tabx[t] = dx
	
		dw = tabw[t]
		dh = tabsh
	
		if (sel)
			draw_box(dx, dy, dw, dh + 1, false, c_background, 1)
	
		tabtitle[t] = string_limit(tabtitle[t], dw - (26 * tab.closeable))
	
		// Close button
		if (tab.closeable)
		{
			if (draw_button_icon("tabclose" + string(tab), dx + dw - 26, dy + 2, 24, 24, false, icons.CLOSE_SMALL))
			{
				tab_close(tab)
				return 0
			}
		}
	
		// Label
		draw_label(tabtitle[t], dx + 8, round(dy + (dh/2)), fa_left, fa_center, (sel ? c_accent : c_text_secondary), (sel ? 1 : a_text_secondary), font_emphasis)
	
		// Outline/border
		if (sel)
		{
			if (t != 0)
				draw_box(dx - 1, dy, 1, dh, false, c_border, a_border)
		
			draw_box(dx + dw - 1, dy, 1, dh + 1, false, c_border, a_border)
		}
		else
		{
			if (t < panel.tab_list_amount)
			{
				if (panel.tab_selected != t + 1)
					draw_box(dx + dw, dy + 2, 1, dh - 4, false, c_border, a_border)
			}
		}
	
		// Click
		if (app_mouse_box(dx, dy, dw, dh) && !app_mouse_box(dx + dw - (26 * tab.closeable), dy + 2, 24 * tab.closeable, 24))
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
			draw_box(dx, dy, dw, dh, false, c_accent, tab.glow * glow_alpha)
	
		dx += tabw[t]
	}

	// Panel edge
	if (panel = panel_map[?"right"] || panel = panel_map[?"right_secondary"])
		draw_box(boxx, boxy, 1, boxh, false, c_border, a_border)
	else
		draw_box(boxx + boxw - 1, boxy, 1, boxh, false, c_border, a_border)

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
			draw_box(boxx + tabsw, boxy, min(tab_move_width, tabmaxw - tabsw), tabsh, false, c_accent, panel.list_glow * glow_alpha)
	}

	// Glow
	if (content_tab.glow > 0)
		draw_box(boxx, boxy + tabsh, boxw, boxh - tabsh, false, c_accent, content_tab.glow * glow_alpha)
}

// Border
resizemouseon = false
if (panel = panel_map[?"left"] || panel = panel_map[?"left_secondary"])
{
	draw_gradient(boxx + boxw, boxy, shadow_size, boxh, c_black, shadow_alpha, 0, 0, shadow_alpha)
	if (app_mouse_box(boxx + boxw - 5, boxy, 5, boxh) && tablistmouseon = null && !popup_mouseon && !snackbar_mouseon && !context_menu_mouseon)
	{
		mouse_cursor = cr_size_we
		resizemouseon = true
	}
}
else if (panel = panel_map[?"right"] || panel = panel_map[?"right_secondary"])
{
	draw_gradient(boxx - shadow_size, boxy, shadow_size, boxh, c_black, 0, shadow_alpha, shadow_alpha, 0)
	if (app_mouse_box(boxx, boxy, 5, boxh) && tablistmouseon = null && !popup_mouseon && !snackbar_mouseon && !context_menu_mouseon)
	{
		mouse_cursor = cr_size_we
		resizemouseon = true
	}
}
else if (panel = panel_map[?"bottom"]) 
{
	draw_gradient(boxx, boxy - shadow_size, boxw, shadow_size, c_black, 0, 0, shadow_alpha, shadow_alpha) 
	if (app_mouse_box(boxx, boxy, boxw, 5) && tablistmouseon = null && !popup_mouseon && !snackbar_mouseon && !context_menu_mouseon)
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

// Add shortcuts
/*
if (resizemouseon || window_busy = "panelresize")
{
	// Add shortcuts
	ds_list_clear(shortcut_bar_list)
	shortcut_bar_add(null, e_mouse.LEFT_DRAG, "resizearea")
}

// Add shortcuts
if (tablistmouseon != null)
	shortcut_bar_add(null, e_mouse.LEFT_CLICK, "select")

if (tabmouseon || window_busy = "tabmove" || tablistmouseon != null)
	shortcut_bar_add(null, e_mouse.LEFT_DRAG, "movetab")
*/

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

// Click tab list
if (tablistmouseon != null && mouse_left_pressed)
{
	panel.tab_selected = tablistmouseon
	window_busy = "tabclick"
	tab_move = panel.tab_list[tablistmouseon]
}