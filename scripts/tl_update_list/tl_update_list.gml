/// tl_update_list([root])
/// @arg [root]

var root = true;

if (argument_count > 0)
	root = argument[0]

if (root)
{
	app.tree_update_parent_filter = app
	app.tree_update_extend = true
	ds_list_clear(tree_visible_list)
	ds_list_clear(tree_list_filter)
	level = -1
}
else
{
	// Clear
	level = 0
	level_display = []
	ds_list_clear(tree_list_filter)
	
	// Set parent in "filtered" timeline
	parent_filter = app.tree_update_parent_filter
	
	// Only add visible timelines
	if (tl_update_list_filter(id))
	{
		// Add timeline to visible list and update tree extend
		if (app.tree_update_extend)
		{
			ds_list_add(app.tree_visible_list, id)
			app.tree_update_extend = tree_extend
		}
		
		// Add to parent's "filtered" tree
		ds_list_add(parent_filter.tree_list_filter, id)
		
		// Update "filtered" parent ID
		app.tree_update_parent_filter = id
	}
}

var update, extend;
update = app.tree_update_parent_filter
extend = app.tree_update_extend

for (var t = 0; t < ds_list_size(tree_list); t++)
{
	app.tree_update_parent_filter = update
	app.tree_update_extend = extend
	
	with (tree_list[|t])
		tl_update_list(false)
}

// Connect hierarchy and indent of visible timelines
if (argument_count = 0 && app.timeline_search = "")
{
	for (var t = 0; t < ds_list_size(app.tree_list_filter); t++)
	{
		with (app.tree_list_filter[|t])
			tl_update_list_indent(0)
	}
}