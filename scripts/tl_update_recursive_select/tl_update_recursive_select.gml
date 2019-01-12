/// tl_update_recursive_select()
/// @desc Recursively selects a timeline's children if they inherit their parent's selection

for (var t = 0; t < ds_list_size(tree_list); t++)
{
	with (tree_list[|t])
	{
		if (inherit_select)
		{
			tl_update_recursive_select()
			tl_select()
		}
	}
}