/// tl_update_parent_is_selected()
/// @desc Updates parent_is_selected variable for self and children.

parent_is_selected = false

if (parent != app)
	parent_is_selected = (parent.selected || parent.parent_is_selected)

for (var t = 0; t < ds_list_size(tree_list); t++)
	with (tree_list[|t])
		tl_update_parent_is_selected()
