function color_ease(color, colorgoal)
{
	var rgb_old, rgb_new;
	rgb_old = [color_get_red(color), color_get_green(color), color_get_blue(color)]
	rgb_new = [color_get_red(colorgoal), color_get_green(colorgoal), color_get_blue(colorgoal)]
	
	for (var i = 0; i <= 2; i++)
		rgb_old[i] += (rgb_new[i] - rgb_old[i]) / max(1, 4 / delta)
	
	return make_color_rgb(rgb_old[0], rgb_old[1], rgb_old[2])
}
