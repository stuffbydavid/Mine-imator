/// minecraft_get_color(name)
/// @arg name
/// @desc Returns a Minecraft color based on given name

function minecraft_get_color(name)
{
	// Search swatches
	var keys = string_split(name, ":");
	
	if (array_length(keys) > 1)
	{
		for (var s = 0; s < array_length(minecraft_swatch_array); s++)
		{
			var swatch = minecraft_swatch_array[s];
			
			if (swatch.name != keys[0])
				continue;
			
			for (var c = 0; c < array_length(swatch.colors); c++)
			{
				if (keys[1] != swatch.color_names[c])
					continue;
				else
					return swatch.colors[c];
			}
		}
	}
	
	if (string_contains(name, "#"))
		return hex_to_color(name)
	else
		return c_white
}