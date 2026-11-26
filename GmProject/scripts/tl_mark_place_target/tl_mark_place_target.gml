/// @desc Marks a timeline as the current placement target.

function tl_mark_place_target(active)
{
	if (place_target = active)
		return 0
	
	place_target = active
	
	// Update place parent list
	if (active)
		ds_list_add(render_place_parent_list, id)
	else
		ds_list_delete_value(render_place_parent_list, id)
	
	view_changed(app.build_first_person ? app.view_main : null)
	
	if (type = e_tl_type.MODEL_PART && id = app.place_target_tl_root)
		return 0
	
	for (var t = 0; t < ds_list_size(tree_list); t++)
	{
		with (tree_list[|t])
		{
			parent_is_place_target = active
			tl_mark_place_target(active)
		}
	}
	
	// Mark block parent
	if (!app.place_build && parent != app && type_is_block(parent.type))
		with (parent)
			tl_mark_place_target(active)
}
