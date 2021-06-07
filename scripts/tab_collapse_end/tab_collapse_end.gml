/// tab_collapse_end([divider])
/// @arg [divider]

function tab_collapse_end()
{
	var divider = (argument_count > 0 ? argument[0] : true);
	
	dx -= 16
	dw += 16
	collapse_ani = 1
	collapse_groups--
	
	if (collapse_groups = 0)
		draw_box(content_x, dy, content_width, content_height, false, c_level_middle, 1)
	
	if (divider)
	{
		draw_divide(content_x, dy, content_width - (floor(tab.scrollbar_margin * 12) + 1))
		dy += 8
	}
}
