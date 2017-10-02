/// tl_has_parent(object)
/// @arg object
/// @desc Returns whether the timeline has the given object as parent.

var tl = argument0;

if (parent = tl)
	return true

if (parent = app)
	return false
	
with (parent)
	return tl_has_parent(tl)
