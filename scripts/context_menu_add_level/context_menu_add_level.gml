/// context_menu_add_level(name, x, y)
/// @arg name
/// @arg x
/// @arg y

var name, xx, yy, level;
name = argument0
xx = argument1
yy = argument2
level = new(obj_context_menu_level)

level.name = name
level.level_list = list_init_context_menu(name)
level.level = context_menu_level_amount

level.level_x = xx
level.level_y = yy
level.level_width = level.level_list.width + 8
level.level_height = (ds_list_size(level.level_list.item) * 28) + 8

for (var i = 0; i < ds_list_size(level.level_list.item); i++)
{
	var item = level.level_list.item[|i];
	if (item.divider)
		level.level_height += 8
}

// Base level already exists
if (context_menu_level_amount > 0)
{
	// TODO: Move next to previous menu
	if ((level.level_x + level.level_width + context_menu_level[|0].level_width) < window_width)
		level.level_x += context_menu_level[|0].level_width
	else
		level.level_x -= level.level_width
}

if (level.level_x + level.level_width > window_width)
	level.level_x += window_width - (level.level_x + level.level_width)
		
if (level.level_y + level.level_height > window_height)
	level.level_y += window_height - (level.level_y + level.level_height)

ds_list_add(context_menu_level, level)
context_menu_level_amount++
