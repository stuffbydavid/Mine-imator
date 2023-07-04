/// menu_add_timeline(timeline, level, menu)
/// @arg timeline
/// @arg level
/// @arg menu
/// @desc Adds a new timeline to the dropdown menu.

function menu_add_timeline(tl, level, menu)
{
	if (tl = tl_edit && !menu.menu_include_tl_edit)
		return 0
	
	if (tl = null)
		list_item_add(text_get("timelinenone"), tl)
	else
	{
		list_item_add(string_remove_newline(tl.display_name), tl)
		
		if (ds_list_size(tl.tree_list) && !menu_scroll)
			list_item_add_action(list_item_last, string(tl) + "extend", menu_item_set_extend, tl.tree_extend, tl, null, "left", tl.tree_extend ? "tooltiptlcollapse" : "tooltiptlexpand", spr_chevron_ani)
	}
	
	list_item_last.indent = max(0, level * 32)
	
	if (tl != null && !tl.tree_extend && !menu_scroll)
		return 0
	
	if (tl = null)
		tl = app
	
	for (var t = 0; t < ds_list_size(tl.tree_list); t++)
		menu_add_timeline(tl.tree_list[|t], level + 1, menu)
}
