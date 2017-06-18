/// array3D_get(array, point)
/// @arg array
/// @arg point

gml_pragma("forceinline")

var arr_x = argument0,
	pnt = argument1;
	
var arr_y = arr_x[@ pnt[@ X]];
var arr_z = arr_y[@ pnt[@ Y]];

return arr_z[@ pnt[@ Z]]