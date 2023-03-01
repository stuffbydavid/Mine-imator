/// draw_box_hover(x, y, width, height, alpha)
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg alpha
/// @desc Drawing separate full boxes for each side because drawing primitive outlines isn't consistent on all computers

function draw_box_hover()
{
	var xx, yy, width, height, size, color, alpha;
	xx = argument[0]
	yy = argument[1]
	width = argument[2]
	height = argument[3]
	size = 2
	color = c_hover
	alpha = a_hover * argument[4]
	
	if (alpha = 0)
		return 0
	
	var t = percent(argument[4], 0, .75);
	draw_outline(xx, yy, width, height, 1, color, alpha * t)
	
	t = percent(argument[4], .25, 1);
	draw_outline(xx - 1, yy - 1, width + 2, height + 2, 1, color, alpha * t)
	
	/*
	
	// Top
	draw_box(xx - size, yy - size, width + (size * 2), size, false, color, alpha)
	
	// Bottom
	draw_box(xx - size, yy + height, width + (size * 2), size, false, color, alpha)
	
	// Left
	draw_box(xx - size, yy, size, height, false, color, alpha)
	
	// Right
	draw_box(xx + width, yy, size, height, false, color, alpha)
	*/
}
