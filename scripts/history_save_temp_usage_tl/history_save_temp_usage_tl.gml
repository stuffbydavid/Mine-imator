/// history_save_temp_usage_tl(template, save, treeobject)
/// @arg template
/// @arg save
/// @arg treeobj
/// @desc Saves the affected timelines recursively.

var temp, save, treeobj;
temp = argument0
save = argument1
treeobj = argument2

for (var t = 0; t < treeobj.tree_amount; t++)
{
	var tl = treeobj.tree[t]
	if (tl.temp = temp)
	{
		save.usage_tl[save.usage_tl_amount] = history_save_tl(tl)
		save.usage_tl_amount++
	}
	else
		history_save_temp_usage_tl(temp, save, tl)
}
