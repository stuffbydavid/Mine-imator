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

view_split = setting_view_split

view_main = new(obj_view)
view_main.overlays = setting_view_main_overlays
view_main.aspect_ratio = setting_view_main_aspect_ratio
view_main.grid = setting_view_main_grid
view_main.gizmos = setting_view_main_gizmos
view_main.fog = setting_view_main_fog
view_main.effects = setting_view_main_effects
view_main.particles = setting_view_main_particles
view_main.location = setting_view_main_location
view_main.quality = e_view_mode.SHADED

view_second = new(obj_view)
view_second.show = setting_view_second_show
view_second.overlays = setting_view_second_overlays
view_second.aspect_ratio = setting_view_second_aspect_ratio
view_second.grid = setting_view_second_grid
view_second.gizmos = setting_view_second_gizmos
view_second.fog = setting_view_second_fog
view_second.effects = setting_view_second_effects
view_second.particles = setting_view_second_particles
view_second.location = setting_view_second_location
view_second.width = setting_view_second_width
view_second.height = setting_view_second_height
view_second.quality = e_view_mode.SHADED

view_render = false
view_render_real_time = true

view_control_edit = null
view_control_edit_view = null
view_control_vec = vec2(0, 0)
view_control_pos = vec2(0, 0)
view_control_flip = false
view_control_value = 0
