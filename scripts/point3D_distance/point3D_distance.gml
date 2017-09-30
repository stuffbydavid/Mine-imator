/// point3D_distance(point1, point2)
/// @arg point1
/// @arg point2

//gml_pragma("forceinline")

var pnt1, pnt2;
pnt1 = argument0
pnt2 = argument1

return vec3_length(point3D_sub(pnt1, pnt2))
