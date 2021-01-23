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
		menu_list = null
		
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

if (menu_steps = 0)
	draw_set_alpha(0)

var itemsx, itemsy;
itemsx = 1
itemsy = menu_amount

var yy, listh, h;
listh = ease(((menu_ani_type = "show") ? "easeoutexpo" : "easeinexpo"), menu_ani) * (menu_type != e_menu.TRANSITION_LIST ? min(itemsy, menu_show_amount) * menu_item_h : menu_height)
h = listh + (12 * menu_scroll_horizontal.needed)

yy = (menu_flip ? (menu_y - h) : (menu_y + menu_button_h))

draw_box(menu_x, yy, menu_w, h, false, c_background, 1)

if (h > 2)
	draw_outline(menu_x, yy, menu_w, h, 1, c_border, a_border, true)

// Hide outline touching button
draw_box(menu_x + 1, yy + (menu_flip), menu_w - 2, h - 1, false, c_background, 1)

// Drop shadow
var shadowy, shadowh, shadowani;
shadowy = (menu_flip ? yy : yy - menu_button_h)
shadowh = h + menu_button_h
shadowani = ease(((menu_ani_type = "show") ? "easeoutexpo" : "easeinexpo"), menu_ani)
draw_dropshadow(menu_x, shadowy, menu_w, shadowh, c_black, shadowani)

content_x = menu_x
content_y = yy
content_width = menu_w
content_height = h

if (window_busy = "menu")
	window_busy = ""

// Scrollbars
content_mouseon = app_mouse_box(menu_x, yy, menu_w, h)
if (menu_ani_type = "" && menu_type != e_menu.TRANSITION_LIST)
{
	if (menu_scroll_vertical.needed && content_mouseon)
		window_scroll_focus = string(menu_scroll_vertical)
	
	if (menu_scroll_horizontal.needed && content_mouseon && keyboard_check(vk_shift))
		window_scroll_focus = string(menu_scroll_horizontal)
	
	menu_scroll_vertical.snap_value = menu_item_h
	scrollbar_draw(menu_scroll_vertical, e_scroll.VERTICAL, menu_x + menu_w - 12, yy, listh, (itemsy * menu_item_h))
	
	scrollbar_draw(menu_scroll_horizontal, e_scroll.HORIZONTAL, menu_x, yy + h - 12, menu_w - (12 * menu_scroll_vertical.needed), menu_list.width)
}
else
{
	menu_scroll_vertical.needed = false
	menu_scroll_horizontal.needed = false
}

content_width = menu_w - (12 * menu_scroll_vertical.needed)
content_mouseon = app_mouse_box(content_x, content_y, content_width, content_height)

var mouseitem = null;
draw_set_font(font_value)
switch (menu_type)
{
	case e_menu.LIST: // Normal list with images and caption
	case e_menu.TIMELINE:
	{
		var dy = yy;
		for (var m = round(menu_scroll_vertical.value / menu_item_h); m < menu_amount; m++)
		{
			var item, itemy, itemh;
			
			if (dy + menu_item_h > yy + h)
				break
			
			item = menu_list.item[|m]
			itemy = dy
			itemh = menu_item_h
			
			list_item_draw(item, menu_x, itemy, content_width, menu_item_h, menu_value = item.value, menu_margin, -menu_scroll_horizontal.value)
			
			if (item.hover)
				mouseitem = item
			
			dy += menu_item_h
		}
		break
	}
	
	case e_menu.TRANSITION_LIST:
	{
		scissor_start(content_x, content_y, content_width, content_height)
		
		menu_transition = menu_transitions(menu_x, yy, menu_w, menu_height)
		
		if (menu_transition != null)
			mouse_left_released = true
		
		scissor_done()
		
		break
	}
	
}

if (menu_type = e_menu.TIMELINE && menu_tl_extend)
{
	app_mouse_clear()
	action_tl_extend(menu_tl_extend)
	list_destroy(menu_list)
	menu_list = menu_timeline_init()
	menu_amount = ds_list_size(menu_list.item)
	
	menu_tl_extend = null
}

// Check click
if (!(menu_scroll_vertical.needed && menu_scroll_vertical.mouseon) && !(menu_scroll_horizontal.needed && menu_scroll_horizontal.mouseon) && mouse_left_released)
{
	var close = false;
	
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
	
	if (menu_type = e_menu.TRANSITION_LIST)
	{
		if (menu_transition != null)
		{
			script_execute(menu_script, menu_transition)
			close = true
		}
		else if (!content_mouseon)
			close = true
	}
	else
		close = true
	
	if (close)
	{
		menu_ani = 1
		menu_ani_type = "hide"
		window_busy = ""
	}
}

if (menu_steps = 0)
	draw_set_alpha(1)

menu_steps++

if (window_busy = "" && menu_ani_type != "hide")
	window_busy = "menu"
