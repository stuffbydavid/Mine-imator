/// tl_update_list([level])
/// @arg [level]

var level;

if (argument_count = 0)
{
    app.tree_list_amount = 0
	level = -1
}
else
{
	level = argument[0]
    tree_pos = app.tree_list_amount
    app.tree_list[app.tree_list_amount] = id
    app.tree_list_level[app.tree_list_amount] = level
    app.tree_list_amount++
    if (!tree_extend)
        return 0
}

for (var t = 0; t < tree_amount; t++)
    with (tree[t])
        tl_update_list(level + 1)
