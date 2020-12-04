/// tl_update_list([level])
/// @arg [level]

if (argument_count = 0)
{
	ds_list_clear(tree_visible_list)
	level = -1
}
else
{
	level = argument[0]
	
	if (app.timeline_search = "" || (app.timeline_search != "" && string_contains(string_upper(display_name), string_upper(app.timeline_search))))
	{
		ds_list_add(app.tree_visible_list, id)
		level_display = []
		
		if (parent != app && app.timeline_search = "")
		{
			level_display = array_copy_1d(parent.level_display)
			level_display = array_add(level_display, true)
			
			// Check if grandparent trees ended, cut off connection display
			if (parent.parent != app)
			{
				if (ds_list_find_index(parent.parent.tree_list, parent) = (ds_list_size(parent.parent.tree_list) - 1))
					level_display[level - 2] = false
			}
		}
	}
	
	if (!tree_extend && app.timeline_search = "")
		return 0
}

for (var t = 0; t < ds_list_size(tree_list); t++)
	with (tree_list[|t])
		tl_update_list(app.timeline_search = "" ? other.level + 1 : 0)
