/// panel_draw_content()

function panel_draw_content()
{
	var minw, minh, maxh, dividew;
	minw = 288
	minh = 160
	maxh = 0
	
	dx = content_x + 12
	dy = content_y + 14
	dw = content_width - 24
	dh = content_height
	tab = content_tab
	dividew = content_width
	
	if (content_direction = e_scroll.VERTICAL)
	{
		if (tab.scroll.needed)
			tab.scrollbar_margin_goal = 1
		else
			tab.scrollbar_margin_goal = 0
		
		dividew -= floor(tab.scrollbar_margin * 12)
		dw -= (tab.scrollbar_margin * 12)
		dy -= tab.scroll.value
	}
	else
	{
		dh -= 30 * tab.scroll.needed
		dx -= tab.scroll.value
	
		// Minimum height
		if (dh < minh)
		{
			if (tab.panel != panel_map[?"bottom"])
				dy -= minh - dh
			dh = minh
		}
	}
	
	if (tab.scroll.needed && content_mouseon && tab != timeline)
		window_scroll_focus = string(tab.scroll)
	
	dx_start = dx
	dy_start = dy
	dw_start = dw
	dh_start = dh
	
	if (!tab.script)
	{
		var columns, cat, catamount, c;
		catamount = 0
		for (c = 0; c < tab.category_amount; c++)
		{
			if (tab.category[c].enabled)
			{
				cat[catamount] = tab.category[c]
				catamount++
			}
		}
		
		columns = 1
		dw = ceil((dw - 8 * (columns - 1)) / columns)
		c = 0
		
		dy = dy_start
		dh = dh_start
		
		dy -= 8
		
		// Content at top of categories
		if (tab.header_script)
		{
			script_execute(tab.header_script)
			maxh = max(dy - dy_start, maxh)
		}
		
		for (var col = 0; col < columns; col++)
		{
			// Number of categories in this column
			var cats = max(1, round(catamount / columns)) 
			if (col = columns - 1)
				cats = catamount - c
			
			repeat (cats)
			{
				tab_control(28)
				draw_subheader(cat[c], content_x + 4, dy, dividew - 4, 28)
				tab_next(false)
				
				// Draw contents
				if (cat[c].show && cat[c].script)
				{
					//draw_box(content_x, dy - 8, dividew, content_height, false, c_level_bottom, 1)
					
					//dy += floor(8 * microani_arr[e_microani.ACTIVE])
					//dy -= 8
					script_execute(cat[c].script)
					
					//draw_box(content_x, dy, dividew, content_height, false, c_level_middle, 1)
				}
				
				if (c < catamount - 1 && cat[c].show && cat[c].script)
				{
					//dy += 8
					draw_divide(content_x, dy, dividew - 1)
					dy += 8
				}
				
				maxh = max(dy - dy_start, maxh)
				c++
			}
		}
	}
	else
	{
		script_execute(tab.script)
		maxh = dy - dy_start
	}
	
	if (tab != timeline)
	{
		// Scrollbar
		if (content_direction = e_scroll.VERTICAL)
			scrollbar_draw(tab.scroll, e_scroll.VERTICAL, content_x + dividew, content_y, content_height, maxh + 32)
		else
			scrollbar_draw(tab.scroll, e_scroll.HORIZONTAL, content_x, content_y + content_height - 35, content_width, dx + dw - content_x + tab.scroll.value + 15)
	}
}
