/// tl_has_child(object)
/// @arg object
/// @desc Returns whether the timeline has the given object as a child.

var tl = argument0;

if (tl = app)
	return false

with (tl)
	if (tl_has_parent(other.id))
		return true

return false
