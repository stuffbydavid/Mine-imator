/// builder_get(buffer, x, y, z)
/// @arg buffer
/// @arg x
/// @arg y
/// @arg z

var buf, xx, yy, zz, t;
buf = argument0
xx = argument1
yy = argument2
zz = argument3

t = builder_get_index(xx, yy, zz)

return buffer_peek(buf, t * 4, buffer_s32)