/// minecraft_mix_colors(arr)
/// @arg arr
/// @desc Mixes an array of colors together. https://minecraft.fandom.com/wiki/Dye

function minecraft_mix_colors(arr)
{
	var rgb, total, avg, maxavg, gain;
	total = [0, 0, 0, 0]
	
	for (var i = 0; i < array_length(arr); i++)
	{
		rgb = [color_get_red(arr[i]), color_get_green(arr[i]), color_get_blue(arr[i])]
		total[0] += rgb[0]
		total[1] += rgb[1]
		total[2] += rgb[2]
		total[3] += max(rgb[0], rgb[1], rgb[2])
	}
	
	avg = vec4_div(total, array_length(arr))
	maxavg = max(avg[0], avg[1], avg[2])
	gain = avg[3] / maxavg
	
	return make_color_rgb(avg[0] * gain, avg[1] * gain, avg[2] * gain)
}