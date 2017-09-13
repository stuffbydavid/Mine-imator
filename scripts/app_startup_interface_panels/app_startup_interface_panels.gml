/// app_startup_interface_panels()

panel_left_bottom = new(obj_panel)
panel_right_bottom = new(obj_panel)
panel_bottom = new(obj_panel)
panel_top = new(obj_panel)
panel_left_top = new(obj_panel)
panel_right_top = new(obj_panel)

panel_list = ds_list_create()
ds_list_add(panel_list, panel_left_bottom)
ds_list_add(panel_list, panel_right_bottom)
ds_list_add(panel_list, panel_bottom)
ds_list_add(panel_list, panel_top)
ds_list_add(panel_list, panel_left_top)
ds_list_add(panel_list, panel_right_top)

panel_bottom.size = 205
panel_top.size = 205

panel_area_x = 0
panel_area_y = 0
panel_area_width = 0
panel_area_height = 0

panel_resize = null
panel_resize_size = 0
