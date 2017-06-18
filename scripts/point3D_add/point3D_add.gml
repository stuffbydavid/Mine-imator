/// point3D_add(point, vector)
/// @arg point
/// @arg vector

gml_pragma("forceinline")

var pnt, vec;
pnt = argument0
vec = argument1

return point3D(pnt[@ X] + vec[@ X], pnt[@ Y] + vec[@ Y], pnt[@ Z] + vec[@ Z])
