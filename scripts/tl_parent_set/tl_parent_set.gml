/// tl_parent_set(parent, [position])
/// @desc Sets the parent
/// @arg parent
/// @arg [position]

if (parent != null)
	tl_parent_remove()

parent = argument[0]
if (argument_count > 1 && argument[1] >= 0)
	parent_pos = argument[1]
else
    parent_pos = parent.tree_amount

tl_parent_add()

update_matrix = true
