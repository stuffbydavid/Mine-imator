/// minecraft_get_swatch(name)
/// @arg name
/// @desc Returns a swatch of Minecraft colors

function minecraft_get_swatch(name)
{
	for (var s = 0; s < array_length(minecraft_swatch_array); s++)
	{
		var swatch = minecraft_swatch_array[s];
		
		if (swatch.name = name)
			return swatch;
	}
	
	return null
}