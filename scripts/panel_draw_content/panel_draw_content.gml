/// panel_draw_content()

var minw, minh, maxh;
minw = 300
minh = 160
maxh = 0

dx = content_x + 15
dy = content_y + 10
dw = content_width - 30
dh = content_height - 20
tab = content_tab

if (content_direction = e_scroll.VERTICAL)
{
	dw -= 30 * tab.scroll.needed
	dy -= tab.scroll.value
}
else
{
	dh -= 30 * tab.scroll.needed
	dx -= tab.scroll.value
	
	// Minimum height
	if (dh < minh)
	{
		if (tab.panel != panel_bottom)
			dy -= minh - dh
		dh = minh
	}
}

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
	columns = clamp(floor(dw / minw), 1, catamount)
	dw = ceil((dw - 8*(columns - 1)) / columns)
	c = 0
	
	for (var col = 0; col < columns; col++)
	{
		// Number of categories in this column
		var cats = max(1, round(catamount / columns)) 
		if (col = columns - 1)
			cats = catamount - c
		
		dy = dy_start
		dh = dh_start
		repeat (cats)
		{
			// Hide button
			tab_control(16)
			if (draw_button_normal(cat[c].name, dx - 3, dy, 16, 16, e_button.CAPTION, cat[c].show, false, true, test(cat[c].show, icons.arrowdown, icons.arrowright)))
				cat[c].show=!cat[c].show
			tab_next()
			
			// Draw contents
			if (cat[c].show)
			{
				script_execute(cat[c].script)
				dy += 10
			}
			
			maxh = max(dy - dy_start, maxh)
			c++
		}
		if (col < columns - 1)
			dx += dw + 8
	}
	
}
else
{
	script_execute(tab.script)
	maxh = dy - dy_start
}

if (tab != timeline) // Scrollbar
{
	content_mouseon=!popup_mouseon
	if (content_direction = e_scroll.VERTICAL)
		scrollbar_draw(tab.scroll, e_scroll.VERTICAL, content_x + content_width - 35, content_y, content_height, maxh + 15, setting_color_buttons, setting_color_buttons_pressed, setting_color_background)
	else
		scrollbar_draw(tab.scroll, e_scroll.HORIZONTAL, content_x, content_y + content_height - 35, content_width, dx + dw - content_x + tab.scroll.value + 15, setting_color_buttons, setting_color_buttons_pressed, setting_color_background)
}
