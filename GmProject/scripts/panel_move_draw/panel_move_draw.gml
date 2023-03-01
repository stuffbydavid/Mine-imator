/// panel_move_draw()

function panel_move_draw()
{
	var boxx, boxy, boxw, boxh, tabsh;
	boxx = mouse_x - (tab_move_box_width/2)
	boxy = mouse_y
	boxw = 300
	boxh = 300
	tabsh = 28
	
	dx = boxx
	dy = boxy
	dw = boxw
	dh = boxh
	
	content_x = boxx
	content_y = boxy
	content_width = boxw
	content_height = boxh
	
	draw_dropshadow(content_x, content_y, content_width, content_width, c_black, 1)
	draw_box(content_x, content_y, content_width, content_width, false, c_level_middle, 1)
	
	// Tab
	draw_set_font(font_label)
	
	var tabname, tabw;
	tabname = tab_get_title(tab_move)
	tabw = min(string_width(tabname) + 16, boxw)
	
	draw_box(dx, dy, dw, tabsh, false, c_level_bottom, 1)
	draw_box(dx, dy + tabsh, dw, 1, false, c_border, a_border)
	
	draw_box(dx, dy, tabw, tabsh + 1, false, c_level_middle, 1)
	
	draw_box(dx + tabw - 1, dy, 1, tabsh + 1, false, c_border, a_border)
	
	draw_label(tabname, floor(dx + 8), round(dy + (tabsh/2)), fa_left, fa_center, c_accent, 1)
	
	// Tab content
	content_y += tabsh
	content_width = boxw
	content_height -= tabsh
	
	content_mouseon = false
	content_tab = tab_move
	content_direction = tab_move_direction
	
	clip_begin(content_x, content_y, content_width, content_width - tabsh)
	panel_draw_content()
	draw_box(content_x, content_y, content_width, content_width, false, c_level_middle, .25)
	
	clip_end()
}
