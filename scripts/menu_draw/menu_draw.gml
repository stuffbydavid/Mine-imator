/// menu_draw()
/// @desc Draws the dropdown menu.

// Animation
if (menu_ani_type = "hide") //Hide
{
	menu_ani -= 0.08 * delta
	if (menu_ani <= 0)
	{
		menu_ani = 0
		menu_name = ""
		list_destroy(menu_list)
		return 0
	}
}
else if (menu_ani_type = "show") //Show
{
	menu_ani += 0.08 * delta
	if (menu_ani >= 1)
	{
		menu_ani = 1
		menu_ani_type = ""
	}
}

if (menu_name = "")
	return 0

var itemsx, itemsy;
itemsx = 1
itemsy = menu_amount

var yy, h;
h = ease(((menu_ani_type = "show") ? "easeoutexpo" : "easeinexpo"), menu_ani) * min(itemsy, menu_show_amount) * menu_item_h
yy = (menu_flip ? (menu_y - h) : (menu_y + menu_button_h))

if (h > 2)
	draw_outline(menu_x, (menu_flip ? yy : yy + 2), menu_w, h - 2, 1, c_border, a_border)
draw_box(menu_x, yy, menu_w, h, false, c_background, 1)
draw_line_ext(menu_x, (menu_flip ? yy + h : yy), menu_x + menu_w, (menu_flip ? yy + h : yy), c_overlay, a_overlay)

// Drop shadow
var shadowy, shadowh, shadowani;
shadowy = (menu_flip ? yy : yy - menu_button_h)
shadowh = h + menu_button_h
shadowani = ease(((menu_ani_type = "show") ? "easeoutexpo" : "easeinexpo"), menu_ani)
draw_dropshadow(menu_x - 1, shadowy - 1, menu_w + 2, shadowh + 2, c_black, shadowani)

content_x = menu_x
content_y = yy
content_width = menu_w
content_height = h

if (window_busy = "menu")
	window_busy = ""

// Scrollbar
content_mouseon = app_mouse_box(menu_x, yy, menu_w, h)
if (menu_ani_type = "")
{
	if (menu_scroll.needed && content_mouseon)
		window_scroll_focus = string(menu_scroll)
	
	menu_scroll.snap_value = menu_item_h
	scrollbar_draw(menu_scroll, e_scroll.VERTICAL, menu_x + menu_w - 9, yy, h, (itemsy * menu_item_h))
}
else
	menu_scroll.needed = false

var mouseitem = null;
draw_set_font(font_value)
switch (menu_type)
{
	case e_menu.LIST: // Normal list with images and caption
	{
		var dy = yy;
		for (var m = round(menu_scroll.value / menu_item_h); m < menu_amount; m++)
		{
			var item, itemy, itemh;
			
			if (dy + menu_item_h > yy + h)
				break
			
			item = menu_list.item[|m]
			itemy = dy
			itemh = menu_item_h
			
			list_item_draw(item, menu_x, itemy, menu_w - 12 * menu_scroll.needed, menu_item_h, menu_value = item.value, menu_margin)
			
			if (item.hover)
				mouseitem = item
			
			dy += menu_item_h
		}
		break
	}
	
}

// Check click
if (!app_mouse_box(menu_x + menu_w - 12, yy, 12 * menu_scroll.needed, h) && mouse_left_released)
{
	menu_ani = 1
	menu_ani_type = "hide"
	window_busy = ""
	
	if (mouseitem)
	{
		menu_ani = 2
		menu_value = mouseitem.value
		
		if (mouseitem.script != null)
			script_execute(mouseitem.script, null)
		else
			script_execute(menu_script, menu_value)
		
		app_mouse_clear()
	}
	
}

if (window_busy = "" && menu_ani_type != "hide")
	window_busy = "menu"
