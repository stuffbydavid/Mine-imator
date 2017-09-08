/// draw_texture(texture, x, y, [xscale, yscale, [color, alpha]])
/// @arg texture
/// @arg x
/// @arg y
/// @arg [xscale
/// @arg yscale
/// @arg [color
/// @arg alpha]]

if (argument_count < 4)
	draw_sprite_ext(argument[0], 0, argument[1], argument[2], 1, 1, 0, c_white, draw_get_alpha())
else if (argument_count < 6)
	draw_sprite_ext(argument[0], 0, argument[1], argument[2], argument[3], argument[4], 0, c_white, draw_get_alpha())
else
	draw_sprite_ext(argument[0], 0, argument[1], argument[2], argument[3], argument[4], 0, argument[5], argument[6] * draw_get_alpha())
