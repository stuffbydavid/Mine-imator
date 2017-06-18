/// tl_parent_remove()
/// @desc Remove from parent's tree.

parent.tree_amount--
for (var t = parent_pos; t < parent.tree_amount; t++) // Push down
{ 
    parent.tree[t] = parent.tree[t + 1]
    parent.tree[t].parent_pos--
}
