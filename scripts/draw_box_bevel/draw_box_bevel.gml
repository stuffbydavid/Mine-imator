/// draw_box_bevel(x, y, width, height, alpha, [light])
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg alpha
/// @arg [light]

function draw_box_bevel()
{
	var xx, yy, width, height, alpha, light;
	xx = argument[0]
	yy = argument[1]
	width = argument[2]
	height = argument[3]
	alpha = argument[4]
	light = false
	
	if (argument_count > 5)
		light = argument[5]
	
	if (light)
	{
		draw_box(xx, yy, 3, height, false, c_white, .6 * alpha) // Left
		draw_box(xx + width - 3, yy, 3, height, false, c_black, .05 * alpha) // Right
		draw_box(xx, yy + height - 3, width, 3, false, c_black, .1 * alpha) // Bottom
		draw_box(xx, yy, width, 3, false, c_white, .8 * alpha) // Top
	}
	else
	{
		draw_box(xx, yy, 3, height, false, c_white, .15 * alpha) // Left
		draw_box(xx + width - 3, yy, 3, height, false, c_black, .1 * alpha) // Right
		draw_box(xx, yy + height - 3, width, 3, false, c_black, .2 * alpha) // Bottom
		draw_box(xx, yy, width, 3, false, c_white, .3 * alpha) // Top
	}
}
