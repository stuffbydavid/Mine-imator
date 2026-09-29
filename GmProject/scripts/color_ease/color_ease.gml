function color_ease(color, colorgoal)
{
	var rgbold, rgbnew;
	rgbold = [ color_get_red(color), color_get_green(color), color_get_blue(color) ]
	rgbnew = [ color_get_red(colorgoal), color_get_green(colorgoal), color_get_blue(colorgoal) ]
	
	for (var i = 0; i <= 2; i++)
		rgbold[i] += (rgbnew[i] - rgbold[i]) / max(1, 4 / delta)
	
	return make_color_rgb(rgbold[0], rgbold[1], rgbold[2])
}
