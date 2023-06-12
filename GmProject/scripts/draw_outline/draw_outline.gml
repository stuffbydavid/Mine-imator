/// draw_outline(x, y, width, height, size, [color, alpha, [inline]])
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg size
/// @arg [color
/// @arg alpha
/// @arg [inline]]

function draw_outline(xx, yy, ww, hh, size, incolor, inalpha, inline = false)
{
	var color, alpha;
	
	color = draw_get_color()
	alpha = draw_get_alpha()
	
	if (!is_undefined(incolor))
	{
		color = incolor
		alpha *= inalpha
		
		if (alpha = 0)
			return 0
	}
	
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
