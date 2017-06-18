/// point4D_homogenize(point)
/// @arg point

gml_pragma("forceinline")

var pnt = argument0;

return point3D(pnt[@ X] / pnt[@ W], pnt[@ Y] / pnt[@ W], pnt[@ Z] / pnt[@ W])
