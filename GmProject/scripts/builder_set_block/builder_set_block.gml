/// CppSeparate void builder_set_block(ScopeAny, IntType, IntType, IntType, IntType, IntType, BoolType)
/// @desc Write a structure block to GM buffers or C++ sections.
/// @arg x
/// @arg y
/// @arg z
/// @arg blockid
/// @arg stateid
/// @arg waterlogged

function builder_set_block(xx, yy, zz, blockid, stateid, waterlogged)
{
	var pos = zz * build_size_xy + yy * build_size[X] + xx;
	buffer_poke(block_obj, pos * 2, buffer_u16, blockid)
	buffer_poke(block_state_id, pos * 2, buffer_u16, stateid)
	buffer_poke(block_waterlogged, pos, buffer_u8, waterlogged)
}
