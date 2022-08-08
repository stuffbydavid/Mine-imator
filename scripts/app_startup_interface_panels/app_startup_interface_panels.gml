/// app_startup_interface_panels()

function app_startup_interface_panels()
{
	panel_map = ds_map_create()
	panel_map[?"left_secondary"] = new_obj(obj_panel)
	panel_map[?"left_secondary"].size = setting_panel_left_bottom_size
	panel_map[?"left_secondary"].location = "left_secondary"
	panel_map[?"right_secondary"] = new_obj(obj_panel)
	panel_map[?"right_secondary"].size = setting_panel_right_bottom_size
	panel_map[?"right_secondary"].location = "right_secondary"
	panel_map[?"bottom"] = new_obj(obj_panel)
	panel_map[?"bottom"].size = setting_panel_bottom_size
	panel_map[?"bottom"].location = "bottom"
	panel_map[?"top"] = new_obj(obj_panel)
	panel_map[?"top"].size = setting_panel_top_size
	panel_map[?"top"].location = "top"
	panel_map[?"left"] = new_obj(obj_panel)
	panel_map[?"left"].size = setting_panel_left_top_size
	panel_map[?"left"].location = "left"
	panel_map[?"right"] = new_obj(obj_panel)
	panel_map[?"right"].size = setting_panel_right_top_size
	panel_map[?"right"].location = "right"
	panel_window_obj = new_obj(obj_panel)
	
	panel_area_x = 0
	panel_area_y = 0
	panel_area_width = 0
	panel_area_height = 0
	
	panel_resize = null
	panel_resize_size = 0
}
