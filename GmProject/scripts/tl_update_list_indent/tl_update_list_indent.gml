/// tl_update_list_indent(level)
/// @arg level

function tl_update_list_indent(tllevel)
{
	indent_level = tllevel
	
	if (parent_filter != app)
	{
		level_display = array_copy_1d(parent_filter.level_display)
		level_display = array_add(level_display, true)
		
		// Check if grandparent trees ended, cut off connection display
		if (parent_filter.parent_filter != app)
		{
			// Check if parent is the last timeline in grandparent's list
			if (ds_list_find_index(parent_filter.parent_filter.tree_list_filter, parent_filter) = (ds_list_size(parent_filter.parent_filter.tree_list_filter) - 1))
				level_display[level - 2] = false
		}
	}
	
	// Update children
	for (var t = 0; t < ds_list_size(tree_list_filter); t++)
	{
		with (tree_list_filter[|t])
			tl_update_list_indent(other.indent_level + 1)
	}
}
