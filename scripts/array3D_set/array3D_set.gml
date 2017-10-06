/// array3D_set(array, size, point, value)
/// @arg array
/// @arg size
/// @arg point
/// @arg value

//gml_pragma("forceinline")

var arr, size, pnt, val;
arr = argument0
size = argument1
pnt = argument2
val = argument3

ds_grid_set(arr, pnt[@ X], pnt[@ Y] * size[@ Z] + pnt[@ Z], val)