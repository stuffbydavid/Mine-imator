/// context_menu_draw_level(i)
/// @arg i

var levelindex, level, aniease;
levelindex = argument0
level = context_menu_level[|levelindex]

// Animation
level.ani += 0.1 * delta
if (level.ani >= 1)
	level.ani = 1
aniease = ease("easeoutexpo", level.ani)

dx = level.level_x
dy = level.level_y
dw = level.level_width
dh = level.level_height * aniease

content_x = dx
content_y = dy
content_width = dw
content_height = dh
content_mouseon = app_mouse_box(dx, dy, dw, dh) && (levelindex >= context_menu_mouseon_level)

if (content_mouseon)
	context_menu_mouseon = true

if (content_mouseon && levelindex > context_menu_mouseon_level)
	context_menu_mouseon_level = levelindex

// Reset mouseon level to base
if (!content_mouseon && (levelindex >= context_menu_mouseon_level))
	context_menu_mouseon_reset = true

draw_dropshadow(dx, dy, dw, dh, c_black, 1)
draw_box(dx, dy, dw, dh, false, c_background, 1)
draw_outline(dx, dy, dw, dh, 1, c_border, a_border, true)

if (level.ani < 1)
	scissor_start(dx, dy, dw, dh)

// Adjust 
dy = level.level_y - ((1 - aniease) * level.level_height)

if (level.level_list != null)
{
	dy += 4
	
	for (var i = 0; i < ds_list_size(level.level_list.item); i++)
	{
		var item = level.level_list.item[|i];
		
		if (item.divider)
			dy += 8
		
		list_item_draw(item, dx, dy + 24 * i, dw, 24, false)
		
		if (item.context_menu_active)
			current_mcroani.value = true
		
		if (app_mouse_box(dx, dy + 24 * i, dw, 24))
			context_menu_mouseon_item = item
	}
}
else
{
	if (script_execute(level.level_script, dx, dy, dw, dh))
		return 0
}

if (level.ani < 1)
	scissor_done()
