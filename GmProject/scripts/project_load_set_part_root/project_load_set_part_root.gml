/// project_load_set_part_root(part_root)
/// @arg part_root

function project_load_set_part_root(part_root)
{
	for (var i = 0; i < ds_list_size(tree_list); i++)
	{
		var tl = tree_list[|i];
		tl.part_root = part_root
		
		with (tl)
			project_load_set_part_root(part_root)
	}
}
