/// builder_get_waterlogged(x, y, z)
/// @arg x
/// @arg y
/// @arg z

var xx, yy, zz, t;
xx = argument0
yy = argument1
zz = argument2

t = builder_get_index(xx, yy, zz)

return buffer_peek(block_waterlogged, t, buffer_u8)