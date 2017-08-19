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
	ds_list_add(app.tree_visible_list, id)
	
	if (!tree_extend)
		return 0
}

for (var t = 0; t < ds_list_size(tree_list); t++)
	with (tree_list[|t])
		tl_update_list(other.level + 1)
