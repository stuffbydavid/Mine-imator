/// tl_update_child_is_animated()
/// Updates whether any child is animated

function tl_update_child_is_animated()
{
	child_is_animated = false
	
	for (var t = 0; t < ds_list_size(tree_list); t++)
	{
		with (tree_list[|t])
		{
			tl_update_child_is_animated()
			
			if (animated || child_is_animated)
				other.child_is_animated = true
		}
	}
}
