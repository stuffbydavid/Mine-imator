/// settings_startup()

setting_project_folder = projects_directory

backup_next = 0
setting_backup = true
setting_backup_time = 10
setting_backup_amount = 3
setting_spawn_objects = true
setting_spawn_cameras = true

setting_tip_show = true
setting_tip_delay = 0.35

setting_view_grid_size_hor = 3
setting_view_grid_size_ver = 3
setting_view_real_time_render = true
setting_view_real_time_render_time = 100

font_main = font_add_lib(data_directory + "opensans.ttf", 12, false, false)
font_main_bold = font_add_lib(data_directory + "opensansbold.ttf", 12, false, false)
font_main_big = font_add_lib(data_directory + "opensansbold.ttf", 18, false, false)

setting_font = font_main
setting_font_bold = font_main_bold
setting_font_big = font_main_big
setting_font_filename = ""

setting_language_filename = language_file

action_setting_color_reset()

setting_timeline_autoscroll = true
setting_timeline_compact = false
setting_timeline_select_jump = true
setting_z_is_up = false

setting_key_new = ord("N")
setting_key_new_control = true
setting_key_import_asset = ord("I")
setting_key_import_asset_control = true
setting_key_open = ord("O")
setting_key_open_control = true
setting_key_save = ord("S")
setting_key_save_control = true
setting_key_undo = ord("Z")
setting_key_undo_control = true
setting_key_redo = ord("Y")
setting_key_redo_control = true
setting_key_play = vk_space
setting_key_play_control = false
setting_key_play_beginning = vk_enter
setting_key_play_beginning_control = false
setting_key_move_marker_right = vk_right
setting_key_move_marker_right_control = false
setting_key_move_marker_left = vk_left
setting_key_move_marker_left_control = false
setting_key_render = vk_f5
setting_key_render_control = false
setting_key_folder = ord("F")
setting_key_folder_control = true
setting_key_select_timelines = ord("A")
setting_key_select_timelines_control = true
setting_key_duplicate_timelines = ord("D")
setting_key_duplicate_timelines_control = true
setting_key_remove_timelines = ord("R")
setting_key_remove_timelines_control = true
setting_key_copy_keyframes = ord("C")
setting_key_copy_keyframes_control = true
setting_key_cut_keyframes = ord("X")
setting_key_cut_keyframes_control = true
setting_key_paste_keyframes = ord("V")
setting_key_paste_keyframes_control = true
setting_key_remove_keyframes = vk_delete
setting_key_remove_keyframes_control = false
setting_key_spawn_particles = ord("S")
setting_key_spawn_particles_control = false
setting_key_clear_particles = ord("C")
setting_key_clear_particles_control = false

setting_key_forward = ord("W")
setting_key_back = ord("S")
setting_key_left = ord("A")
setting_key_right = ord("D")
setting_key_ascend = ord("E")
setting_key_descend = ord("Q")
setting_key_roll_forward = ord("Z")
setting_key_roll_back = ord("C")
setting_key_roll_reset = ord("X")
setting_key_reset = ord("R")
setting_key_fast = vk_space
setting_key_slow = vk_lshift
setting_move_speed = 1
setting_look_sensitivity = 1
setting_fast_modifier = 3
setting_slow_modifier = 0.25

setting_bend_round_default = false
setting_bend_detail = 3
setting_bend_scale = 1.001
setting_schematic_remove_edges = true
setting_liquid_animation = true
setting_texture_filtering = true
setting_transparent_texture_filtering = false
setting_texture_filtering_level = 1
setting_block_brightness = 0.75

setting_render_ssao = true
setting_render_ssao_radius = 12
setting_render_ssao_power = 1
setting_render_ssao_samples = 16
setting_render_ssao_blur_passes = 2
setting_render_ssao_color = c_black

setting_render_shadows = true
setting_render_shadows_sun_buffer_size = 2048
setting_render_shadows_spot_buffer_size = 512
setting_render_shadows_point_buffer_size = 256
setting_render_shadows_blur_quality = 20
setting_render_shadows_blur_size = 1

setting_render_dof = true
setting_render_dof_blur_size = 0.02

setting_render_aa = true
setting_render_aa_power = 1

setting_render_watermark = trial_version

settings_open()

texture_set_mipmap_level(setting_texture_filtering_level)