/// tl_has_child(object)
/// @arg object
/// @desc Returns whether the timeline has the given object as a child.

if (argument0 = app)
    return false

with (argument0)
    if (tl_has_parent(other.id))
        return true

return false
