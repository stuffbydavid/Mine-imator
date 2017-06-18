/// array3D_set(array, point, value)
/// @arg array
/// @arg point
/// @arg value

gml_pragma("forceinline")

var arr_x = argument0,
	pnt = argument1,
	value = argument2;

// X
if (pnt[@ X] >= array_length_1d(arr_x) || !is_array(arr_x[@ pnt[@ X]]))
	arr_x[@ pnt[@ X]] = array()
var arr_y = arr_x[@ pnt[@ X]];

// Y
if (pnt[@ Y] >= array_length_1d(arr_y) || !is_array(arr_y[@ pnt[@ Y]]))
	arr_y[@ pnt[@ Y]] = array()
var arr_z = arr_y[@ pnt[@ Y]];

// Z
arr_z[@ pnt[@ Z]] = value