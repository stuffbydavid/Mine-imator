/// app_startup_interface_panels()

panel_map = ds_map_create()
panel_map[?"left_bottom"] = new(obj_panel)
panel_map[?"left_bottom"].size = setting_panel_left_bottom_size
panel_map[?"left_bottom"].location = "left_bottom"
panel_map[?"right_bottom"] = new(obj_panel)
panel_map[?"right_bottom"].size = setting_panel_right_bottom_size
panel_map[?"right_bottom"].location = "right_bottom"
panel_map[?"bottom"] = new(obj_panel)
panel_map[?"bottom"].size = setting_panel_bottom_size
panel_map[?"bottom"].location = "bottom"
panel_map[?"top"] = new(obj_panel)
panel_map[?"top"].size = setting_panel_top_size
panel_map[?"top"].location = "top"
panel_map[?"left_top"] = new(obj_panel)
panel_map[?"left_top"].size = setting_panel_left_top_size
panel_map[?"left_top"].location = "left_top"
panel_map[?"right_top"] = new(obj_panel)
panel_map[?"right_top"].size = setting_panel_right_top_size
panel_map[?"right_top"].location = "right_top"

panel_area_x = 0
panel_area_y = 0
panel_area_width = 0
panel_area_height = 0

panel_resize = null
panel_resize_size = 0
