/// draw_box_rounded(x, y, width, height, [color, alpha, [roundlefttop, roundrighttop, roundrightbottom, roundleftbottom, [roundsize, roundsprite]]])
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg [color
/// @arg alpha
/// @arg [roundlefttop
/// @arg roundrighttop
/// @arg roundrightbottom
/// @arg roundleftbottom
/// @arg [roundsize
/// @arg roundsprite]]]

function draw_box_rounded()
{
	var xx, yy, w, h;
	var roundlefttop, roundrighttop, roundrightbottom, roundleftbottom;
	var roundsize, roundsprite;
	var oldcolor, oldalpha;
	xx = argument[0]
	yy = argument[1]
	w = argument[2]
	h = argument[3]
	
	if (argument_count > 4)
	{
		oldcolor = draw_get_color()
		oldalpha = draw_get_alpha()
		draw_set_color(argument[4])
		draw_set_alpha(oldalpha * argument[5])
	}
	
	if (argument_count > 6)
	{
		roundlefttop = argument[6]
		roundrighttop = argument[7]
		roundrightbottom = argument[8]
		roundleftbottom = argument[9]
	}
	else
	{
		roundlefttop = true
		roundrighttop = true
		roundrightbottom = true
		roundleftbottom = true
	}
	
	if (argument_count > 10)
	{
		roundsize = argument[10]
		roundsprite = argument[11]
	}
	else
	{
		roundsize = 2
		roundsprite = spr_rounded_2
	}
	
	draw_primitive_begin(pr_trianglefan)
	
	draw_vertex(xx + w / 2, yy + h / 2)
	
	// Left top
	if (roundlefttop)
	{
		draw_vertex(xx, yy + roundsize)
		draw_vertex(xx + roundsize, yy + roundsize)
		draw_vertex(xx + roundsize, yy)
	}
	else
		draw_vertex(xx, yy)
		
	// Right top
	if (roundrighttop)
	{
		draw_vertex(xx + w-roundsize, yy)
		draw_vertex(xx + w-roundsize, yy + roundsize)
		draw_vertex(xx + w, yy + roundsize)
	}
	else
		draw_vertex(xx + w, yy)
	
	// Right bottom
	if (roundrightbottom)
	{
		draw_vertex(xx + w, yy + h-roundsize)
		draw_vertex(xx + w-roundsize, yy + h-roundsize)
		draw_vertex(xx + w-roundsize, yy + h)
	}
	else
		draw_vertex(xx + w, yy + h)
	
	// Left bottom
	if (roundleftbottom)
	{
		draw_vertex(xx + roundsize, yy + h)
		draw_vertex(xx + roundsize, yy + h-roundsize)
		draw_vertex(xx, yy + h-roundsize)
	}
	else
		draw_vertex(xx, yy + h)
	
	draw_vertex(xx, yy + roundsize * roundlefttop)
	
	draw_primitive_end()
	
	if (roundlefttop)
		draw_image(roundsprite, 0, xx + roundsize, yy + roundsize, 1, 1, draw_get_color(), 1)
	if (roundrighttop)
		draw_image(roundsprite, 0, xx + w-roundsize, yy + roundsize, 1, 1, draw_get_color(), 1, -90)
	if (roundrightbottom)
		draw_image(roundsprite, 0, xx + w-roundsize, yy + h-roundsize, 1, 1, draw_get_color(), 1, -180)
	if (roundleftbottom)
		draw_image(roundsprite, 0, xx + roundsize, yy + h-roundsize, 1, 1, draw_get_color(), 1, -270)
	
	if (argument_count > 4) {
		draw_set_color(oldcolor)
		draw_set_alpha(oldalpha)
	}
}
