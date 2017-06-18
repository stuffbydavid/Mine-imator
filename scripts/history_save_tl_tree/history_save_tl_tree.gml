/// history_save_tl_tree(treeobj)
/// @arg treeobj

var treeobj = argument0;

for (var t = 0; t < treeobj.tree_amount; t++)
{
    var tl = treeobj.tree[t];
    if (tl.select && !tl.part_of)
	{
        id.tl[tl_amount] = history_save_tl(tl)
        tl_amount++
    }
	else
        history_save_tl_tree(tl)
}
