/// minecraft_mix_colors(arr)
/// @arg arr
/// @desc Mixes an array of colors together. https://minecraft.wiki/w/Dye

function minecraft_mix_colors(arr)
{
	var colors, rgb, totalRgb, totalMax, avgRgb, avgMax, maxOfAvg, gain;
	colors = array_length(arr)
	totalRgb = [0, 0, 0]
	totalMax = 0
	
	for (var i = 0; i < colors; i++)
	{
		rgb = [color_get_red(arr[i]), color_get_green(arr[i]), color_get_blue(arr[i])]
		totalRgb[0] += rgb[0]
		totalRgb[1] += rgb[1]
		totalRgb[2] += rgb[2]
		totalMax	+= max(rgb[0], rgb[1], rgb[2])
	}
	
	avgRgb[0]	= totalRgb[0] / colors
	avgRgb[1]	= totalRgb[1] / colors
	avgRgb[2]	= totalRgb[2] / colors
	avgMax		= totalMax / colors
	
	maxOfAvg = max(avgRgb[0], avgRgb[1], avgRgb[2])
	gain = avgMax / maxOfAvg
	
	return make_color_rgb(avgRgb[0] * gain, avgRgb[1] * gain, avgRgb[2] * gain)
}