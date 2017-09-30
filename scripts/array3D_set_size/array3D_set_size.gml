/// array3D_set_size(array, size)
/// @arg array

var arr, size;
arr = argument0
size = argument1

ds_grid_resize(arr, size[@ X], size[@ Y] * size[@ Z])