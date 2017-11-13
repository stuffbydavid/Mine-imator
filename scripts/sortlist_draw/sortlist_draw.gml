/// sortlist_draw(sortlist, x, y, width, height, select)
/// @arg sortlist
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg select
/// @desc Draws the given sorted list at x, y. Runs a script when a new value is selected.

var slist, xx, yy, w, h, select;
var itemh, colsh, dy;
var tbxwid, filterx, filtery;
slist = argument0
xx = argument1
yy = argument2
w = argument3
h = argument4
select = argument5

if (xx + w < content_x || xx > content_x + content_width || yy + h<content_y || yy > content_y + content_height)
	return 0

// Item height
itemh = 28

// Columns
colsh = 32

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
		icon = test(slist.sort_asc, icons.ARROW_UP_SMALL, icons.ARROW_DOWN_SMALL)
		
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

// Background
draw_box(xx, yy + colsh, w, h - colsh, false, setting_color_background, 1)

// List
for (var i = round(slist.scroll.value / itemh); i < ds_list_size(slist.display_list); i++)
{
	var value, dw;
	
	if (dy + itemh > yy + h)
		break
		
	value = slist.display_list[|i]
	dw = w - 30 * slist.scroll.needed
	if (select = value)
		draw_box(xx, dy, dw, itemh, false, setting_color_highlight, 1)
		
	for (var c = 0; c < slist.columns; c++)
	{
		var dx, text, wid;
		dx = xx + floor(slist.column_x[c] * w) + 5
		wid = slist.column_w[c] - 5
		if (c = slist.columns - 1 && slist.scroll.needed)
			wid -= 30
		text = string_limit(string(sortlist_column_get(slist, value, c)), wid)
		draw_label(text, dx, dy + itemh / 2, fa_left, fa_middle, test(select = value, setting_color_highlight_text, null), 1)
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
scrollbar_draw(slist.scroll, e_scroll.VERTICAL, xx + w - 30, yy + colsh, floor((h - colsh) / itemh) * itemh, ds_list_size(slist.display_list) * itemh, setting_color_buttons, setting_color_buttons_pressed, setting_color_background_scrollbar)

// Filter box
if (slist.filter)
{
	slist.filter_ani = min(slist.filter_ani + 0.1 * delta, 1)
	tbxwid = ease("easeoutcirc", slist.filter_ani) * 100
}
else
{
	slist.filter_ani = max(slist.filter_ani - 0.1 * delta, 0)
	tbxwid = ease("easeincirc", slist.filter_ani) * 100
}
filterx = xx + w-tbxwid
filtery = yy + h+5
if (draw_button_normal("listsearch", filterx - 18, filtery + 2, 16, 16, e_button.NO_TEXT, slist.filter, false, true, icons.SEARCH)) 
{
	slist.filter = !slist.filter
	sortlist_update(slist)
	if (slist.filter)
		window_focus = string(slist.filter_tbx)
}

if (tbxwid > 0)
	if (draw_inputbox("listsearch", filterx, filtery, tbxwid, text_get("listsearch"), slist.filter_tbx, null, 0, 20, 1))
		sortlist_update(slist)
