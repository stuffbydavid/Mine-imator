/// draw_image(sprite, subimage, x, y, [xscale, yscale, [color, alpha, [rotation]]])
/// @arg sprite
/// @arg subimage
/// @arg x
/// @arg y
/// @arg [xscale
/// @arg yscale
/// @arg [color
/// @arg alpha
/// @arg [rotation]]]

function draw_image()
{
	if (argument_count < 5)
		draw_sprite_ext(argument[0], argument[1], argument[2], argument[3], 1, 1, 0, c_white, draw_get_alpha())
	else if (argument_count < 7)
		draw_sprite_ext(argument[0], argument[1], argument[2], argument[3], argument[4], argument[5], 0, c_white, draw_get_alpha())
	else if (argument_count < 9)
		draw_sprite_ext(argument[0], argument[1], argument[2], argument[3], argument[4], argument[5], 0, argument[6], argument[7] * draw_get_alpha())
	else
		draw_sprite_ext(argument[0], argument[1], argument[2], argument[3], argument[4], argument[5], argument[8], argument[6], argument[7] * draw_get_alpha())
}
