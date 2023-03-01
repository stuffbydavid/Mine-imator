/// lengthdir_z(length, direction)
/// @arg length
/// @arg direction

function lengthdir_z(length, dir)
{
	gml_pragma("forceinline")
	
	return -lengthdir_y(length, dir)
}
