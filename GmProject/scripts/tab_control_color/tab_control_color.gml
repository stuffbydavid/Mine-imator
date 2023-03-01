/// tab_control_color()

function tab_control_color()
{
	if (!app.panel_compact && tab_collumns_count > 1)
		tab_control(ui_small_height + (label_height + 8))
	else
		tab_control(ui_small_height)
}
