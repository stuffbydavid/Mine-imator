/// context_menu_add_level(name, x, y, [item])
/// @arg name
/// @arg x
/// @arg y
/// @arg [item]

var name, xx, yy, name, script, level;
name = argument[0]
xx = argument[1]
yy = argument[2]
item = null

if (argument_count > 3)
	item = argument[3]

if (item != null)
	script = item.context_menu_script
else
	script = null

level = new(obj_context_menu_level)

level.name = name
level.level_x = xx
level.level_y = yy
level.level = context_menu_level_amount
level.ani = 0

// Calculate level size
if (script = null)
{
	level.level_list = list_init_context_menu(name)
	level.level_width = level.level_list.width + 8
	level.level_height = (ds_list_size(level.level_list.item) * 24) + 8
	level.script = null
	
	for (var i = 0; i < ds_list_size(level.level_list.item); i++)
	{
		var item = level.level_list.item[|i];
		if (item.divider)
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
	// If less than half of the menu is off-screen, place menu at bottom of window
	if (level.level_y + level.level_height/2 < window_height)
		level.level_y += window_height - (level.level_y + level.level_height)
	else
		level.level_y -= level.level_height
}

ds_list_add(context_menu_level, level)
context_menu_level_amount++
