/// CppSeparate IntType block_mesh_get_index(IntType, IntType, IntType, IntType, IntType)
/// @desc Returns the array index of a block mesh containing the given block.
/// @arg x
/// @arg y
/// @arg z
/// @arg meshesx
/// @arg meshesy

function block_mesh_get_index(xx, yy, zz, meshesx, meshesy)
{
	return ((zz div block_mesh_size) * meshesy + (yy div block_mesh_size)) * meshesx + (xx div block_mesh_size)
}
