/// app_startup_interface_views()

view_area_x = 0
view_area_y = 0
view_area_width = 0
view_area_height = 0

view_click_x = 0
view_click_y = 0

view_resize_split = 0
view_resize_width = 0
view_resize_height = 0

view_glow_left_top = 0
view_glow_top = 0
view_glow_right_top = 0
view_glow_right = 0
view_glow_right_bottom = 0
view_glow_bottom = 0
view_glow_left_bottom = 0
view_glow_left = 0

view_split = 0.5

view_main = new(obj_view)
view_second = new(obj_view)
view_second.show = false
view_second.location = "rightbottom"
view_second.controls = false
view_second.aspect_ratio = true

view_render = false
view_render_real_time = true

view_control_edit = null
view_control_edit_view = null
view_control_vec = vec2(0, 0)
view_control_pos = vec2(0, 0)
view_control_flip = false
view_control_value = 0
