/// tl_has_child(object)
/// @arg object
/// @desc Returns whether the timeline has the given object as a child.

function tl_has_child(tl)
{
	if (tl = app)
		return false
	
	for (var i = 0; i < ds_list_size(tree_list); i++)
		with (tree_list[|i])
			if (id = tl || tl_has_child(tl))
				return true
	
	return false
}
