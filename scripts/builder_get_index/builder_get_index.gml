/// builder_get_index(x, y, z)
/// @arg x
/// @arg y
/// @arg z

function builder_get_index(xx, yy, zz)
{
	gml_pragma("forceinline")
	
	return zz * build_size_x * build_size_y + yy * build_size_x + xx
}
