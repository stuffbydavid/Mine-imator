/// builder_set(buffer, x, y, z, value)
/// @arg buffer
/// @arg x
/// @arg y
/// @arg z
/// @arg val

var buf, xx, yy, zz, val, t;
buf = argument0
xx = argument1
yy = argument2
zz = argument3
val = argument4

t = builder_get_index(xx, yy, zz)

buffer_seek(buf, buffer_seek_start, t * 4)
buffer_write(buf, buffer_s32, val)