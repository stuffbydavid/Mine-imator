/// CppSeparate IntType surface_create_ext2(IntType, IntType, IntType, BoolType, BoolType)
/// @desc Creates a new surface with additional settings to toggle the depth buffer.

function surface_create_ext2(width, height, format, depth = true, depthonly = false)
{
	return surface_create(width, height, format)
}
