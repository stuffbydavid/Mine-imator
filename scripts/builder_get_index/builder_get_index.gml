/// builder_get_index(x, y, z)
/// @arg x
/// @arg y
/// @arg z

gml_pragma("forceinline")

var xx, yy, zz;
xx = argument0
yy = argument1
zz = argument2

return zz * build_size_x * build_size_y + yy * build_size_x + xx