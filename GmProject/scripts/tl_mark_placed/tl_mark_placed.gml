/// tl_mark_placed(active)
/// Marks a timeline as currently placing so it's ignored during depth/normal pass.

function tl_mark_placed(active)
{
	placed = active
	
	if (app.place_build)
	{
		depth = active ? no_limit : 0
		tl_update_depth()
	}
	
	for (var t = 0; t < ds_list_size(tree_list); t++)
	{
		with (tree_list[|t])
		{
			parent_is_placed = active
			tl_mark_placed(active)
		}
	}
}
