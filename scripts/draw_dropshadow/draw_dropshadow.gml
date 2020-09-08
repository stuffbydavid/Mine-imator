/// draw_dropshadow(x, y, width, height, color, alpha)
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg color
/// @arg alpha

var xx, yy, width, height, color, alpha;
xx = argument0
yy = argument1
width = argument2
height = argument3
color = argument4
alpha = argument5

var slicesize, offset, drawx, drawy;
slicesize = 27
offset = 16
drawx = xx - offset
drawy = yy - offset
width -= (11 * 2)
height -= (11 * 2)

// Top
draw_sprite_part_ext(spr_dropshadow, 0, 0, 0, slicesize, slicesize, drawx, drawy, 1, 1, color, alpha)
drawx += slicesize
draw_sprite_part_ext(spr_dropshadow, 0, slicesize, 0, 1, slicesize, drawx, drawy, width, 1, color, alpha)
drawx += width
draw_sprite_part_ext(spr_dropshadow, 0, slicesize + 1, 0, slicesize, slicesize, drawx, drawy, 1, 1, color, alpha)

// Middle
drawx = xx - offset
drawy += slicesize
draw_sprite_part_ext(spr_dropshadow, 0, 0, slicesize, slicesize, 1, drawx, drawy, 1, height, color, alpha)
drawx += slicesize + width
draw_sprite_part_ext(spr_dropshadow, 0, slicesize + 1, slicesize, slicesize, 1, drawx, drawy, 1, height, color, alpha)

// Bottom
drawx = xx - offset
drawy += height
draw_sprite_part_ext(spr_dropshadow, 0, 0, slicesize + 1, slicesize, slicesize, drawx, drawy, 1, 1, color, alpha)
drawx += slicesize
draw_sprite_part_ext(spr_dropshadow, 0, slicesize, slicesize + 1, 1, slicesize, drawx, drawy, width, 1, color, alpha)
drawx += width
draw_sprite_part_ext(spr_dropshadow, 0, slicesize + 1, slicesize + 1, slicesize, slicesize, drawx, drawy, 1, 1, color, alpha)
