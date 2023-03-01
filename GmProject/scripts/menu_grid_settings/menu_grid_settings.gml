/// menu_grid_settings()

function menu_grid_settings()
{
	draw_set_font(font_label)
	
	var draggerwid;
	draggerwid = text_max_width("viewgridrows", "viewgridcolumns") + 16 + dragger_width
	
	tab_control_dragger()
	draw_dragger("viewgridrows", dx, dy, dragger_width, project_grid_rows, 0.05, 1, 10, 3, 1, tbx_grid_rows, action_project_grid_rows, null, true)
	tab_next()
	
	tab_control_dragger()
	draw_dragger("viewgridcolumns", dx, dy, dragger_width, project_grid_columns, 0.05, 1, 10, 3, 1, tbx_grid_columns, action_project_grid_columns, null, true)
	tab_next()
	
	settings_menu_w = (draggerwid + 24)
}
