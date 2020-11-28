/// context_menu_draw_level(i)
/// @arg i

var i = argument0;
var level = context_menu_level[|i];

dx = level.level_x
dy = level.level_y
dw = level.level_width
dh = level.level_height

content_x = dx
content_y = dy
content_width = dw
content_height = dh
content_mouseon = app_mouse_box(dx, dy, dw, dh) && (i >= context_menu_mouseon_level)

if (content_mouseon)
	context_menu_mouseon = true

if (content_mouseon && i > context_menu_mouseon_level)
	context_menu_mouseon_level = i

// Reset mouseon level to base
if (!content_mouseon && (i >= context_menu_mouseon_level))
	context_menu_mouseon_reset = true

draw_dropshadow(dx, dy, dw, dh, c_black, 1)
draw_outline(dx, dy, dw, dh, 1, c_border, a_border)
draw_box(dx, dy, dw, dh, false, c_background, 1)

if (level.level_list != null)
{
	dy += 4
	
	for (var i = 0; i < ds_list_size(level.level_list.item); i++)
	{
		var item = level.level_list.item[|i];
	
		if (item.divider)
			dy += 8
	
		list_item_draw(item, dx, dy + 28 * i, dw, 28, item.context_menu_active, 8)
	
		if (app_mouse_box(dx, dy + 28 * i, dw, 28))
			context_menu_mouseon_item = item
	}
}
else
{
	script_execute(level.level_script, dx, dy, dw, dh)
}