/// tl_parent_add()
/// @desc Add to parent's tree

for (var t = parent.tree_amount; t > parent_pos; t--) // Push up
{
    parent.tree[t] = parent.tree[t - 1]
    parent.tree[t].parent_pos++
}

parent.tree[parent_pos] = id
parent.tree_amount++
