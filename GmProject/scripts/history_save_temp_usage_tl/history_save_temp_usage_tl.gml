/// history_save_temp_usage_tl(template, save, treeobject)
/// @arg template
/// @arg save
/// @arg treeobj
/// @desc Saves the affected timelines recursively.

function history_save_temp_usage_tl(temp, save, treeobj)
{
	for (var t = 0; t < ds_list_size(treeobj.tree_list); t++)
	{
		var tl = treeobj.tree_list[|t]
		if (tl.temp = temp)
		{
			save.usage_tl_save_obj[save.usage_tl_amount] = history_save_tl(tl)
			save.usage_tl_amount++
		}
		else
			history_save_temp_usage_tl(temp, save, tl)
	}
}
