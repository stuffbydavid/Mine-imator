/// builder_set(grid, x, y, z, value)
/// @arg grid
/// @arg x
/// @arg y
/// @arg z
/// @arg val

var grid, xx, yy, zz, val, t;
grid = argument0
xx = argument1
yy = argument2
zz = argument3
val = argument4
t = zz * build_size_x * build_size_y + yy * build_size_x + xx

ds_grid_set(grid, t div build_size_sqrt, t mod build_size_sqrt, val)