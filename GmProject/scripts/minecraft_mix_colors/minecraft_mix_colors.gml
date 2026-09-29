/// @desc Mixes an array of colors together. https://minecraft.wiki/w/Dye
/// @arg colors

function minecraft_mix_colors(arr)
{
	var colors, rgb, totalrgb, totalmax, avgrgb, avgmax, maxofavg, gain;
	colors = array_length(arr)
	totalrgb = [0, 0, 0]
	totalmax = 0
	
	for (var i = 0; i < colors; i++)
	{
		rgb = [color_get_red(arr[i]), color_get_green(arr[i]), color_get_blue(arr[i])]
		totalrgb[0] += rgb[0]
		totalrgb[1] += rgb[1]
		totalrgb[2] += rgb[2]
		totalmax	+= max(rgb[0], rgb[1], rgb[2])
	}
	
	avgrgb[0]	= totalrgb[0] / colors
	avgrgb[1]	= totalrgb[1] / colors
	avgrgb[2]	= totalrgb[2] / colors
	avgmax		= totalmax / colors
	
	maxofavg = max(avgrgb[0], avgrgb[1], avgrgb[2])
	gain = avgmax / maxofavg
	
	return make_color_rgb(avgrgb[0] * gain, avgrgb[1] * gain, avgrgb[2] * gain)
}
