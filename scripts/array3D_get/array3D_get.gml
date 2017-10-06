/// array3D_get(array, size, point)
/// @arg array
/// @arg size
/// @arg point

//gml_pragma("forceinline")

var arr, size, pnt;
arr = argument0
size = argument1
pnt = argument2

return ds_grid_get(arr, pnt[@ X], pnt[@ Y] * size[@ Z] + pnt[@ Z])