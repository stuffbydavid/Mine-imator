/// draw_shortcut_bar()

function shortcut_bar_draw()
{
	if (!setting_show_shortcuts_bar)
		return 0
	
	content_x = 0
	content_y = window_height - 28
	content_width = window_width
	content_height = 28
	
	dx = content_x + 12
	dy = content_y
	dw = content_width
	dh = 28
	
	draw_box(content_x, content_y, content_width, content_height, false, c_level_top, 1)
	draw_divide(content_x, content_y, content_width)
	draw_gradient(content_x, content_y - shadow_size, content_width, shadow_size, c_black, 0, 0, shadow_alpha, shadow_alpha)
	
	shortcut_bar_update()
	
	for (var i = 0; i < ds_list_size(shortcut_bar_list); i++)
		shortcut_draw(shortcut_bar_list[|i])
}
