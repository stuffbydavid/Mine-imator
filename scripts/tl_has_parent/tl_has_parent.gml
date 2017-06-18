/// tl_has_parent(object)
/// @arg object
/// @desc Returns whether the timeline has the given object as parent.

if (parent = argument0)
	return true

if (parent = app)
	return false
	
with (parent)
	return tl_has_parent(argument0)
