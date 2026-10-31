function history_save_tl_tree(treeobj)
{
	for (var t = 0; t < ds_list_size(treeobj.tree_list); t++)
	{
		var tl = treeobj.tree_list[|t];
		if (tl.selected && (tl.part_of = null || tl.part_of.type = e_tl_type.SCENERY))
		{
			tl_save_obj[tl_save_amount] = history_save_tl(tl)
			tl_save_amount++
		}
		else
			history_save_tl_tree(tl)
	}
}
