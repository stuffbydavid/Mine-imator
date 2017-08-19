/// menu_add_timeline(timeline, level)
/// @arg timeline
/// @arg level
/// @desc Adds a new timeline to the dropdown menu.

var tl, level, item;
tl = argument0
level = argument1

if (tl = tl_edit && !menu_include_tl_edit)
	return 0

item = new(obj_menuitem)
item.value = tl
item.level = max(0, level)

menu_item[menu_amount] = item
menu_amount++

if (tl != app && !tl.tree_extend)
	return 0

for (var t = 0; t < ds_list_size(tl.tree_list); t++)
	menu_add_timeline(tl.tree_list[|t], level + 1)
