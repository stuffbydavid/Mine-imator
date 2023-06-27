/// context_menu_add_level(name, x, y, [item])
/// @arg name
/// @arg x
/// @arg y
/// @arg [item]

function context_menu_add_level(name, xx, yy, item = null)
{
	var script, level;
	if (item != null)
		script = item.context_menu_script
	else
		script = null
	
	level = new_obj(obj_context_menu_level)
	level.name = name
	level.level_x = xx
	level.level_y = yy
	level.level = context_menu_level_amount
	level.ani = 0
	level.flip = false
	
	context_menu_window = window_get_current()
	
	// Calculate level size
	if (script = null)
	{
		level.level_list = list_init_context_menu(name)
		level.level_width = level.level_list.width + 8
		level.level_height = (ds_list_size(level.level_list.item) * 24) + 8
		level.script = null
		
		for (var i = 0; i < ds_list_size(level.level_list.item); i++)
		{
			if (level.level_list.item[|i].divider)
				level.level_height += 8
		}
	}
	else
	{
		level.level_list = null
		level.level_width = item.context_menu_width
		level.level_height = item.context_menu_height
		level.level_script = script
		
		level.level_y -= level.level_height/2
	}
	
	// Base level already exists
	if (context_menu_level_amount > 0)
	{
		// TODO: Move next to previous menu
		if ((level.level_x + level.level_width + context_menu_level[|0].level_width) < window_width)
			level.level_x += (context_menu_level[|0].level_width)
		else
			level.level_x -= (level.level_width + 1)
		
		level.level_y -= 4
	}
	
	if (level.level_x + level.level_width > window_width)
		level.level_x += window_width - (level.level_x + level.level_width)
	
	if (level.level_y + level.level_height > window_height)
	{
		level.level_y -= level.level_height
		level.flip = true
	}
	
	ds_list_add(context_menu_level, level)
	context_menu_level_amount++
	
	return level
}
