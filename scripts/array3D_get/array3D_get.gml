/// array3D_get(array, zsize, x, y, z)
/// @arg array
/// @arg zsize
/// @arg x
/// @arg y
/// @arg z

gml_pragma("forceinline")
return ds_grid_get(argument0, argument2, argument3 * argument1 + argument4)