/// tl_mark_place_target(active)
/// Marks a timeline as the current placement target

function tl_mark_place_target(active)
{
	if (place_target = active)
		return 0
	
	place_target = active
	
	for (var t = 0; t < ds_list_size(tree_list); t++)
	{
		with (tree_list[|t])
		{
			parent_is_place_target = active
			tl_mark_place_target(active)
		}
	}
	
	// Mark block parent
	if (parent != app && type_is_block(parent.type))
		with (parent)
			tl_mark_place_target(active)
}
