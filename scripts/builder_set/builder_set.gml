/// builder_set(buffer, x, y, z, value)
/// @arg buffer
/// @arg x
/// @arg y
/// @arg z
/// @arg val

function builder_set(buf, xx, yy, zz, val)
{
	var t = builder_get_index(xx, yy, zz);
	
	buffer_seek(buf, buffer_seek_start, t * 4)
	buffer_write(buf, buffer_s32, val)
}
