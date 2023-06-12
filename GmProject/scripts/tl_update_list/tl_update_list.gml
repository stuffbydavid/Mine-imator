/// tl_update_list([root, level, collapsed])
/// @arg [root
/// @arg level
/// @arg collapsed]

function tl_update_list()
{
	var root, tllevel, collapsed;
	root = true
	tllevel = -1
	collapsed = false
	
	if (argument_count > 0)
	{
		root = argument[0]
		tllevel = argument[1]
		collapsed = argument[2]
	}
	
	if (root)
	{
		app.tree_update_parent_filter = app
		app.tree_update_extend = true
		app.tree_update_color = null
		app.tree_close_parent = null
		ds_list_clear(tree_visible_list)
		ds_list_clear(tree_list_filter)
		ds_list_clear(project_timeline_list)
		level = -1
		indent_level = -1
	}
	else
	{
		// Clear
		level = tllevel
		level_display = []
		tree_contents = array_create(e_tl_type.amount - 1)
		
		ds_list_clear(tree_list_filter)
		
		// Set parent in "filtered" timeline
		parent_filter = app.tree_update_parent_filter
		
		if (color_tag != null)
			app.tree_update_color = color_tag
		
		// Only add visible timelines
		if (tl_update_list_filter(id))
		{
			// Add timeline to visible list and update tree extend
			if (app.tree_update_extend)
			{
				ds_list_add(app.tree_visible_list, id)
				app.tree_update_extend = tree_extend
			}
			
			if (!tree_extend && app.tree_close_parent = null)
				app.tree_close_parent = id
			
			// Add to parent's "filtered" tree
			ds_list_add(parent_filter.tree_list_filter, id)
			
			if (id != app.tree_close_parent && app.tree_close_parent != null)
				app.tree_close_parent.tree_contents[type]++
			
			// Update "filtered" parent ID
			app.tree_update_parent_filter = id
		}
		
		// Add to list of timelines
		ds_list_add(app.project_timeline_list, id)
	}
	
	var update, extend, color;
	update = app.tree_update_parent_filter
	extend = app.tree_update_extend
	color = app.tree_update_color
	
	for (var t = 0; t < ds_list_size(tree_list); t++)
	{
		app.tree_update_parent_filter = update
		app.tree_update_extend = extend
		app.tree_update_color = color
		
		with (tree_list[|t])
			tl_update_list(false, other.level + 1, app.tree_close_parent != null)
	}
	
	if (!collapsed)
		app.tree_close_parent = null
	
	// Connect hierarchy and indent of visible timelines
	if (argument_count = 0 && app.timeline_search = "")
	{
		for (var t = 0; t < ds_list_size(app.tree_list_filter); t++)
		{
			with (app.tree_list_filter[|t])
				tl_update_list_indent(0)
		}
	}
}
