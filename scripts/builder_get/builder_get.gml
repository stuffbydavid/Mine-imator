/// builder_get(buffer, x, y, z)
/// @arg buffer
/// @arg x
/// @arg y
/// @arg z

function builder_get(buf, xx, yy, zz)
{
	var t = builder_get_index(xx, yy, zz);
	
	return buffer_peek(buf, t * 4, buffer_s32)
}
