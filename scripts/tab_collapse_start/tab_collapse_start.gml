/// tab_collapse_start()

function tab_collapse_start()
{
	collapse_groups++
	draw_box(content_x, dy, content_width, content_height, false, c_level_bottom, 1)
	
	dx += 16
	dw -= 16
	
	dy += -8 + (collapse_ani * 8)
	dy += 8
}
