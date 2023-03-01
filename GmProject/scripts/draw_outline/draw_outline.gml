/// draw_outline(x, y, width, height, size, [color, alpha, [inline]])
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg size
/// @arg [color
/// @arg alpha
/// @arg [inline]]

function draw_outline()
{
	var xx, yy, ww, hh, size, color, alpha, inline;
	xx = argument[0]
	yy = argument[1]
	ww = argument[2]
	hh = argument[3]
	size = argument[4]
	color = draw_get_color()
	alpha = draw_get_alpha()
	inline = false
	
	if (argument_count > 5)
	{
		color = argument[5]
		alpha *= argument[6]
		
		if (alpha = 0)
			return 0
	}
	
	if (argument_count > 7)
		inline = argument[7]
	
	if (inline)
	{
		xx += size
		yy += size
		ww -= size * 2
		hh -= size * 2
	}
	
	// Top
	draw_box(xx - size, yy - size, ww + (size * 2), size, false, color, alpha)
	
	// Bottom
	draw_box(xx - size, yy + hh, ww + (size * 2), size, false, color, alpha)
	
	// Left
	draw_box(xx - size, yy, size, hh, false, color, alpha)
	
	// Right
	draw_box(xx + ww, yy, size, hh, false, color, alpha)
}
