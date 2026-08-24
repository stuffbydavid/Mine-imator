/// draw_label(string, x, y, [halign, valign, [color, alpha, [font, [separation, width]]]])
/// @arg string
/// @arg x
/// @arg y
/// @arg [halign
/// @arg valign
/// @arg [color
/// @arg alpha
/// @arg [font
/// @arg [separation
/// @arg [width]]]]

function draw_label()
{
	var str, xx, yy, halign, valign, color, alpha, font, separation, width;
	var oldcolor, oldalpha;
	var strwid, strhei, strx, stry;
	
	str = argument[0]
	xx = argument[1]
	yy = argument[2]
	strx = xx
	stry = yy
	separation = -1
	width = -1
	
	if (argument_count <= 7)
	{
		strwid = string_width(str)
		strhei = string_height(str)
		
		// Return
		if (xx + strwid < content_x || xx > content_x + content_width || yy + strhei < content_y || yy > content_y + content_height)
			return 0
	}
	
	if (argument_count > 3)
	{
		halign = argument[3]
		valign = argument[4]
		draw_set_halign(halign)
		draw_set_valign(valign)
		
		if (argument_count <= 7)
		{
			if (halign = fa_right)
				strx = xx - strwid
			else if (halign = fa_center)
				strx = xx - strwid/2
			
			if (valign = fa_middle)
				stry = yy - strhei/2
			else if (valign = fa_bottom)
				stry = yy - strhei
			
			// Reset and return
			if (strx + strwid < 0 || strx > content_x + content_width || stry + strhei < 0 || stry > content_y + content_height)
			{
				draw_set_halign(fa_left)
				draw_set_valign(fa_top)
				
				return 0
			}
		}
		
		// Color/alpha
		if (argument_count > 5)
		{
			color = argument[5]
			alpha = argument[6]
			
			if (color != null)
			{
				oldcolor = draw_get_color()
				draw_set_color(color)
			}
			
			if (alpha < 1)
			{
				oldalpha = draw_get_alpha()
				draw_set_alpha(oldalpha * alpha)
			}
			
			// Custom font
			if (argument_count > 7)
			{
				font = argument[7]
				draw_set_font(font)
				
				strwid = string_width(str)
				strhei = string_height(str)
		
				if (halign = fa_right)
					strx = xx - strwid
				else if (halign = fa_center)
					strx = xx - strwid/2
		
				if (valign = fa_middle)
					stry = yy - strhei/2
				else if (valign = fa_bottom)
					stry = yy - strhei
		
				// Reset and return
				if (strx + strwid < 0 || strx > content_x + content_width || stry + strhei < 0 || stry > content_y + content_height)
				{
					draw_set_halign(fa_left)
					draw_set_valign(fa_top)
			
					if (color != null)
						draw_set_color(oldcolor)
			
					if (alpha < 1)
						draw_set_alpha(oldalpha)
			
					return 0
				}
				
				// Separation/width
				if (argument_count > 8)
				{
					separation = argument[8]
					width = argument[9]
				}
			}
		}
	}
	
	if (separation = -1 && width = -1)
		draw_text(xx, yy, str)
	else
		draw_text_ext(xx, yy, str, separation, width)
	
	// Reset
	if (argument_count > 3)
	{
		draw_set_halign(fa_left)
		draw_set_valign(fa_top)
		
		if (argument_count > 5)
		{
			if (color != null)
				draw_set_color(oldcolor)
			
			if (alpha < 1)
				draw_set_alpha(oldalpha)
		}
	}
}
