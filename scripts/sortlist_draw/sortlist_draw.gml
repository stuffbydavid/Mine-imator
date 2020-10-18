/// sortlist_draw(sortlist, x, y, width, height, select, [filter])
/// @arg sortlist
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg select
/// @arg [filter]
/// @desc Draws the given sorted list at x, y. Runs a script when a new value is selected.

var slist, xx, yy, w, h, select, filter;
var itemh, colsh, dy;
slist = argument[0]
xx = argument[1]
yy = argument[2]
w = argument[3]
h = argument[4]
select = argument[5]

if (argument_count > 6)
	filter = argument[6]
else
	filter = true

if (xx + w < content_x || xx > content_x + content_width || yy + h < content_y || yy > content_y + content_height)
	return 0

// Item height
itemh = 28

// Columns
colsh = 28

// Draw filter
if (filter)
{
	if (draw_button_icon("listfilter" + string(slist), xx, yy, 28, 28, !ds_list_empty(slist.filter_list), icons.FILTER, null, false, "tooltipfilterlist"))
	{
		menu_settings_set(xx, yy + 28, "listfilter" + string(slist), 28)
		settings_menu_script = sortlist_filters_draw
		settings_menu_sortlist = slist
	}

	if (settings_menu_name = "listfilter" + string(slist))
		current_mcroani.holding = true
}

if (draw_inputbox("listsearch" + string(slist), xx + (44 * filter), yy, w - (44 * filter), 28, text_get("listsearch"), slist.search_tbx, null))
{
	slist.search = (slist.search_tbx.text != "")
	
	sortlist_update(slist)
}

h -= 36
yy += 36

if (h < colsh)
	return 0

// Dragging
if (window_busy = "sortlist_resize" && sortlist_resize = slist)
{
	slist.column_x[sortlist_resize_column] = sortlist_resize_column_x + (mouse_x - mouse_click_x) / w
	slist.column_x[sortlist_resize_column] = clamp(0, slist.column_x[sortlist_resize_column], 0.9)
	if (sortlist_resize_column > 0)
		slist.column_x[sortlist_resize_column] = max(slist.column_x[sortlist_resize_column], slist.column_x[sortlist_resize_column - 1] + 0.1)
	if (sortlist_resize_column < slist.columns - 1)
		slist.column_x[sortlist_resize_column] = min(slist.column_x[sortlist_resize_column], slist.column_x[sortlist_resize_column + 1] - 0.1)
		
	mouse_cursor = cr_size_we
	if (!mouse_left)
	{
		window_busy = ""
		app_mouse_clear()
	}
}

for (var c = 0; c < slist.columns; c++)
{
	var dx, icon;
	dx = floor(slist.column_x[c] * w)
	
	// Set width
	if (c = slist.columns - 1)
		slist.column_w[c] = ceil(w - dx)
	else
		slist.column_w[c] = ceil(slist.column_x[c + 1] * w) - dx
		
	// Resize?
	if (c > 0 && app_mouse_box(xx + dx - 5, yy, 10, colsh) && content_mouseon)
	{
		mouse_cursor = cr_size_we
		if (mouse_left_pressed)
		{
			sortlist_resize = slist
			sortlist_resize_column = c
			sortlist_resize_column_x = slist.column_x[c]
			window_busy = "sortlist_resize"
		}
	}
	
	// Button
	icon = null
	if (slist.column_sort = c)
		icon = (slist.sort_asc ? icons.SORT_UP : icons.SORT_DOWN)
		
	if (sortlist_draw_button("column" + slist.column_name[c], xx + dx, yy, slist.column_w[c], colsh, slist.column_sort = c, icon, (c = 0), (c = slist.columns - 1)))
	{
		if (slist.column_sort = c)
		{
			if (slist.sort_asc)
			{
				slist.column_sort = null
				slist.sort_asc = false
			}
			else
				slist.sort_asc = true
		}
		else
			slist.column_sort = c
		
		sortlist_update(slist)
	}
}

// Items
dy = yy + colsh

// Outline
draw_outline(xx, yy, w, h, 1, c_border, a_border)

// List
draw_set_font(font_value)

for (var i = round(slist.scroll.value / itemh); i < ds_list_size(slist.display_list); i++)
{
	var value, dw;
	
	if (dy + itemh > yy + h)
		break
	
	value = slist.display_list[|i]
	dw = w - 12 * slist.scroll.needed
	
	if (select = value)
		draw_box(xx, dy, dw, itemh, false, c_overlay, a_overlay)
	
	if (i != round(slist.scroll.value / itemh))
		draw_line_ext(xx, dy, xx + dw, dy, c_border, a_border)
	
	for (var c = 0; c < slist.columns; c++)
	{
		var dx, text, wid, islast;
		dx = xx + floor(slist.column_x[c] * w) + 8
		wid = slist.column_w[c] - 8
		if (c = slist.columns - 1 && slist.scroll.needed)
			wid -= 12
		
		islast = (c = slist.columns - 1) && (c != 0)
		
		text = string_limit(string(sortlist_column_get(slist, value, c)), wid)
		draw_label(text, dx + ((wid - 8) * islast), dy + itemh / 2, islast ? fa_right : fa_left, fa_middle, (select = value) ? c_accent : c_text_main, (select = value) ? 1 : a_text_main)
	}
	
	if (app_mouse_box(xx, dy, dw, itemh) && content_mouseon)
	{
		mouse_cursor = cr_handpoint
		if (mouse_left_pressed)
		{
			window_focus = string(slist.scroll)
			if (slist.can_deselect && select = value)
				script_execute(slist.script, null)
			else
				script_execute(slist.script, value)
			app_mouse_clear()
		}
	}
	
	dy += itemh
}

// Scrollbar
slist.scroll.snap_value = itemh
scrollbar_draw(slist.scroll, e_scroll.VERTICAL, xx + w - 7, yy + colsh, floor((h - colsh) / itemh) * itemh, ds_list_size(slist.display_list) * itemh)
