/// builder_set(grid, x, y, z)
/// @arg grid
/// @arg x
/// @arg y
/// @arg z

var grid, xx, yy, zz, t;
grid = argument0
xx = argument1
yy = argument2
zz = argument3
t = zz * build_size_x * build_size_y + yy * build_size_x + xx

return ds_grid_get(grid, t div build_size_sqrt, t mod build_size_sqrt)