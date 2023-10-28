/// menu_add_timeline(timeline, root, level, menu)
/// @arg timeline
/// @arg root
/// @arg level
/// @arg menu
/// @desc Adds a new timeline to the dropdown menu.

function menu_add_timeline(tl, root, level, menu)
{
	if (tl = tl_edit && !menu.menu_include_tl_edit)
		return 0
	
	if (tl = null)
		list_item_add(text_get("timelinenone"), tl)
	else
	{
		var caption = "";
		
		if (menu_expose && tl.parent != app)
		{
			caption = root.display_name
			
			if (tl.part_of != null)
			{
				if (tl.part_of.parent != app)
				{
					if (tl.part_of.parent = root)
						caption += "/" + tl.part_of.display_name
					else
						caption += "/.../" + tl.part_of.display_name
				}
				else	
					caption = tl.part_of.display_name
			}
			else if (root != tl.parent)
				caption += "/.../" + tl.parent.display_name
		}
		
		list_item_add(string_remove_newline(tl.display_name), tl, caption)
		
		if (ds_list_size(tl.tree_list) && !menu_expose)
			list_item_add_action(list_item_last, string(tl) + "extend", menu_item_set_extend, tl.tree_extend, tl, null, "left", tl.tree_extend ? "tooltiptlcollapse" : "tooltiptlexpand", spr_chevron_ani)
	}
	
	if (!menu_expose)
		list_item_last.indent = max(0, level * 32)
	
	if (tl != null && !tl.tree_extend && !menu_expose)
		return 0
	
	if (tl = null)
		tl = app
	
	for (var t = 0; t < ds_list_size(tl.tree_list); t++)
		menu_add_timeline(tl.tree_list[|t], (tl = app) ? tl.tree_list[|t] : root, level + 1, menu)
}
