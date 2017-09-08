/// draw_texture_part(texture, x, y, left, top, width, height, [xscale, yscale, [color, alpha]])
/// @arg texture
/// @arg x
/// @arg y
/// @arg left
/// @arg top
/// @arg width
/// @arg height
/// @arg [xscale
/// @arg yscale
/// @arg [color
/// @arg alpha]]

if (argument_count < 8)
	draw_sprite_part_ext(argument[0], 0, argument[3], argument[4], argument[5], argument[6], argument[1], argument[2], 1, 1, c_white, draw_get_alpha())
else if (argument_count < 10)
	draw_sprite_part_ext(argument[0], 0, argument[3], argument[4], argument[5], argument[6], argument[1], argument[2], argument[7], argument[8], c_white, draw_get_alpha())
else
	draw_sprite_part_ext(argument[0], 0, argument[3], argument[4], argument[5], argument[6], argument[1], argument[2], argument[7], argument[8], argument[9], argument[10] * draw_get_alpha())