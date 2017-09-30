/// point2D_equal(point1, point2)
/// @arg point1
/// @arg point2

//gml_pragma("forceinline")

var pnt1, pnt2;
pnt1 = argument0
pnt2 = argument1

return (pnt1[@ X] == pnt2[@ X] && pnt1[@ Y] == pnt2[@ Y])
