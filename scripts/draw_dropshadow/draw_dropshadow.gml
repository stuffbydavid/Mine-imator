/// draw_dropshadow(x, y, width, height, color, alpha)
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg color
/// @arg alpha

function draw_dropshadow(xx, yy, width, height, color, alpha)
{
	alpha = alpha * draw_get_alpha() * .75
	
	var slicesize, offset, drawx, drawy;
	slicesize = 27
	offset = 16
	drawx = xx - offset
	drawy = yy - offset
	width -= (11 * 2)
	height -= (11 * 2)
	
	if (width < 0 || height < 0)
		return 0
	
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
}
