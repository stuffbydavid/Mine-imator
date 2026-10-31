/// @arg string
/// @arg x
/// @arg y
/// @arg [halign]
/// @arg [valign]
/// @arg [color]
/// @arg [alpha]
/// @arg [font]
/// @arg [separation]
/// @arg [width]

function draw_label(str, xx, yy, halign = null, valign = null, color = null, alpha = null, font = null, separation = -1, width = -1)
{
	var align, customfont, setcolor, setalpha;
	var strwid, strhei, strx, stry;
	var oldcolor, oldalpha;
	
	align = halign != null
	customfont = font != null
	strx = xx
	stry = yy
	
	if (!customfont)
	{
		strwid = string_width(str)
		strhei = string_height(str)
		
		if (xx + strwid < content_x || xx > content_x + content_width || yy + strhei < content_y || yy > content_y + content_height)
			return 0
	}
	
	if (align)
	{
		draw_set_halign(halign)
		draw_set_valign(valign)
		
		if (customfont)
		{
			draw_set_font(font)
			strwid = string_width(str)
			strhei = string_height(str)
		}
		
		if (halign = fa_right)
			strx -= strwid
		else if (halign = fa_center)
			strx -= strwid/2
		
		if (valign = fa_middle)
			stry -= strhei/2
		else if (valign = fa_bottom)
			stry -= strhei
		
		if (strx + strwid < 0 || strx > content_x + content_width || stry + strhei < 0 || stry > content_y + content_height)
		{
			draw_set_halign(fa_left)
			draw_set_valign(fa_top)
			return 0
		}
	}
	
	setcolor = color != null
	setalpha = alpha != null && alpha < 1
	if (setcolor)
	{
		oldcolor = draw_get_color()
		draw_set_color(color)
	}
	if (setalpha)
	{
		oldalpha = draw_get_alpha()
		draw_set_alpha(oldalpha * alpha)
	}

	if (separation = -1 && width = -1)
		draw_text(xx, yy, str)
	else
		draw_text_ext(xx, yy, str, separation, width)
	
	if (align)
	{
		draw_set_halign(fa_left)
		draw_set_valign(fa_top)
	}
	if (setcolor)
		draw_set_color(oldcolor)
	if (setalpha)
		draw_set_alpha(oldalpha)
}
