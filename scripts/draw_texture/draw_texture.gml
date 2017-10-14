/// draw_texture(texture, x, y, [xscale, yscale, [color, alpha]])
/// @arg texture
/// @arg x
/// @arg y
/// @arg [xscale
/// @arg yscale
/// @arg [color
/// @arg alpha]]

draw_texture_start()

if (argument_count < 4)
	draw_texture_part(argument[0], argument[1], argument[2], 0, 0, texture_width(argument[0]), texture_height(argument[0]))
else if (argument_count < 6)
	draw_texture_part(argument[0], argument[1], argument[2], 0, 0, texture_width(argument[0]), texture_height(argument[0]), argument[3], argument[4])
else
	draw_texture_part(argument[0], argument[1], argument[2], 0, 0, texture_width(argument[0]), texture_height(argument[0]), argument[3], argument[4], argument[5], argument[6])
	
draw_texture_done()