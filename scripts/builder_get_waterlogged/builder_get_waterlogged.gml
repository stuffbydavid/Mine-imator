/// builder_get_waterlogged(x, y, z)
/// @arg x
/// @arg y
/// @arg z

function builder_get_waterlogged(xx, yy, zz)
{
	var t = builder_get_index(xx, yy, zz);

	return buffer_peek(block_waterlogged, t, buffer_u8)
}
