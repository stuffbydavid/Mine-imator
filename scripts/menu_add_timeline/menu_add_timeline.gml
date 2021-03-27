/// menu_add_timeline(timeline, level, menu)
/// @arg timeline
/// @arg level
/// @arg menu
/// @desc Adds a new timeline to the dropdown menu.

var tl, level, menu;
tl = argument0
level = argument1
menu = argument2

if (tl = tl_edit && !menu.menu_include_tl_edit)
	return 0

if (tl = null)
	list_item_add(text_get("timelinenone"), tl)
else
{
	list_item_add(string_remove_newline(tl.display_name), tl)
	
	if (ds_list_size(tl.tree_list))
		list_item_add_action(list_item_last, string(tl) + "extend", menu_timeline_extend, tl.tree_extend, tl, icons.PLUS, "left", tl.tree_extend ? "tooltiptlcollapse" : "tooltiptlexpand", spr_chevron_ani)
}

list_item_last.indent = max(0, level * 32)

//action_tl_extend()

/*
item = new(obj_menuitem)
item.value = tl
item.level = max(0, level)

menu_item[menu_amount] = item
menu_amount++
*/

if (tl != null && !tl.tree_extend)
	return 0

if (tl = null)
	tl = app
	
for (var t = 0; t < ds_list_size(tl.tree_list); t++)
	menu_add_timeline(tl.tree_list[|t], level + 1, menu)
