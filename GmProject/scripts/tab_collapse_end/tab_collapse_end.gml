/// tab_collapse_end([divider])
/// @arg [divider]

function tab_collapse_end(divider = true)
{
	collapse_ani = 1
	collapse_groups--
	
	draw_box(content_x, dy, content_width, content_height, false, c_level_middle, 1)
	
	if (collapse_groups > 0)
		draw_box(content_x, dy, content_width, content_height, false, c_level_bottom, .5 * collapse_groups)
	
	dx -= 16
	dw += 16
	
	if (divider)
	{
		draw_divide(content_x, dy, content_width - (floor(tab.scroll.needed * 12) + 1))
		dy += 8
	}
}
