/// menu_overlay_settings()

draw_set_font(font_emphasis)

var draggerwid, switchwid;
draggerwid = text_max_width("viewoverlaygridrows", "viewoverlaygridcolumns") + 16
switchwid = text_max_width("viewoverlayaspectratio", "viewoverlaygrid") + 16 + 24

tab_control_switch()
if (draw_switch("viewoverlayaspectratio", dx, dy, settings_menu_view.aspect_ratio, null))
	settings_menu_view.aspect_ratio = !settings_menu_view.aspect_ratio
tab_next()

tab_control_switch()
if (draw_switch("viewoverlaygizmos", dx, dy, settings_menu_view.gizmos, null))
	settings_menu_view.gizmos = !settings_menu_view.gizmos
tab_next()

draw_divide(content_x, dy, content_width)
dy += 8

tab_control_switch()
if (draw_switch("viewoverlaygrid", dx, dy, settings_menu_view.grid, null))
	settings_menu_view.grid = !settings_menu_view.grid
tab_next()

tab_control_dragger()
draw_dragger("viewoverlaygridrows", dx, dy, 64, project_grid_rows, 0.05, 1, 10, 3, 1, tbx_grid_rows, action_project_grid_rows, null, true, !settings_menu_view.grid)
tab_next()

tab_control_dragger()
draw_dragger("viewoverlaygridcolumns", dx, dy, 64, project_grid_columns, 0.05, 1, 10, 3, 1, tbx_grid_columns, action_project_grid_columns, null, true, !settings_menu_view.grid)
tab_next()

settings_menu_w = (max(draggerwid + 64, switchwid) + 24)
