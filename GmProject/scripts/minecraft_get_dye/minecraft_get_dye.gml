/// @desc Returns the closest Minecraft dye name for a color.
/// @arg color
/// @arg [glowing]

function minecraft_get_dye(color, glowing = false)
{
	var closest, mindif;
	closest = "black"
	mindif = no_limit

	for (var i = 0; i < array_length(minecraft_swatch_dyes.colors); i++)
	{
		var name, candidate, red, green, blue, dif;
		name = string(minecraft_swatch_dyes.color_names[i])
		candidate = (glowing ? minecraft_get_color("text_glow:" + name) : minecraft_swatch_dyes.colors[i])
		red = color_get_red(color) - color_get_red(candidate)
		green = color_get_green(color) - color_get_green(candidate)
		blue = color_get_blue(color) - color_get_blue(candidate)
		dif = red * red + green * green + blue * blue

		if (dif < mindif)
		{
			mindif = dif
			closest = name
		}
	}

	return closest
}
