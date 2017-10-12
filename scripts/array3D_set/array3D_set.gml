/// array3D_set(array, zsize, x, y, z, value)
/// @arg array
/// @arg zsize
/// @arg x
/// @arg y
/// @arg z

gml_pragma("forceinline")
ds_grid_set(argument0, argument2, argument3 * argument1 + argument4, argument5)