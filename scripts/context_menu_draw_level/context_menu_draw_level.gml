/// context_menu_draw_level(i)
/// @arg i

function context_menu_draw_level(argument0)
{
	var levelindex, level, alphaease, aniease;
	levelindex = argument0
	level = context_menu_level[|levelindex]
	
	// Animation
	if (context_menu_ani = "" || context_menu_ani = "open")
	{
		level.ani += 0.07 * delta
		if (level.ani >= 1)
			level.ani = 1
	}
	else
	{
		level.ani -= 0.125 * delta
		if (level.ani <= 0)
			level.ani = 0
	}
	
	aniease = ease("easeoutexpo", level.ani)
	alphaease = aniease
	aniease = 1
	
	dw = level.level_width
	dh = level.level_height * aniease
	dx = level.level_x
	dy = (level.flip ? (level.level_y + (level.level_height - dh)) : level.level_y)
	
	content_x = dx
	content_y = dy
	content_width = dw
	content_height = dh
	content_mouseon = app_mouse_box(dx, dy, dw, dh) && (levelindex >= context_menu_mouseon_level)
	
	context_menu_min_x = min(dx, context_menu_min_x)
	context_menu_min_y = min(dy, context_menu_min_y)
	context_menu_max_x = max(dx + dw, context_menu_max_x)
	context_menu_max_y = max(dy + dh, context_menu_max_y)
	
	if (content_mouseon)
		context_menu_mouseon = true
	
	if (content_mouseon && levelindex > context_menu_mouseon_level)
		context_menu_mouseon_level = levelindex
	
	// Reset mouseon level to base
	if (!content_mouseon && (levelindex >= context_menu_mouseon_level))
		context_menu_mouseon_reset = true
	
	draw_set_alpha(alphaease)
	
	draw_dropshadow(dx, dy, dw, dh, c_black, 1)
	draw_box(dx, dy, dw, dh, false, c_level_top, 1)
	draw_outline(dx, dy, dw, dh, 1, c_border, a_border, true)
	
	if (level.ani < 1)
		scissor_start(dx, dy, dw, dh)
	
	// Adjust 
	dy = (level.flip ? dy : (level.level_y - ((1 - aniease) * level.level_height)))
	
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
				current_microani.value = true
			
			if (app_mouse_box(dx, dy + 24 * i, dw, 24))
				context_menu_mouseon_item = item
		}
	}
	else
	{
		if (script_execute(level.level_script, dx, dy, dw, dh))
		{
			draw_set_alpha(1)
			return 0
		}
	}
	
	if (level.ani < 1)
		scissor_done()
	
	draw_set_alpha(1)
}
