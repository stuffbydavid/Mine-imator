/// @arg [height]

function tab_control_menu(height = 24)
{
	var labelheight = ((window_compact && !app.panel_compact) ? 0 : label_height + 8);
	tab_control(labelheight + height)
}
