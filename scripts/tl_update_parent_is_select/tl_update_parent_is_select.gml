/// tl_update_parent_is_select()
/// @desc Updates parent_is_select variable for self and children.

parent_is_select = false

if (parent != app)
	parent_is_select = (parent.select || parent.parent_is_select)

for (var t = 0; t < tree_amount; t++)
	with (tree[t])
		tl_update_parent_is_select()
