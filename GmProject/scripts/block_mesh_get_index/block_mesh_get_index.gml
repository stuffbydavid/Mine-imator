/// CppSeparate IntType block_mesh_get_index(IntType, IntType, IntType, IntType, IntType)
/// @desc Returns the array index of a block mesh containing the given block.
/// @arg x
/// @arg y
/// @arg z
/// @arg meshwidth
/// @arg meshheight

function block_mesh_get_index(xx, yy, zz, meshwidth, meshheight)
{
	return ((zz div block_mesh_size) * meshheight + (yy div block_mesh_size)) * meshwidth + (xx div block_mesh_size)
}
