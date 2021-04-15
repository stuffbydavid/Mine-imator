/// settings_startup()

trial_startup()

setting_minecraft_assets_version = minecraft_version
setting_minecraft_assets_new_version = ""
setting_minecraft_assets_new_format = 0
setting_minecraft_assets_new_changes = ""
setting_minecraft_assets_new_image = ""

setting_project_folder = projects_directory

closed_toast_list = ds_list_create()

backup_next = 0
setting_backup = true
setting_backup_time = 10
setting_backup_amount = 3
setting_spawn_objects = true
setting_spawn_cameras = true
setting_unlimited_values = false

setting_view_real_time_render = true
setting_view_real_time_render_time = 1000

setting_theme = theme_light
setting_accent = 3
setting_accent_custom = hex_to_color("03A9F4")

setting_language_filename = language_file

setting_timeline_autoscroll = true
setting_timeline_compact = false
setting_timeline_select_jump = true
setting_timeline_hide_ghosts = false
setting_z_is_up = false
setting_smooth_camera = false
setting_search_variants = true
setting_show_shortcuts_bar = true

setting_toolbar_location = "top"
setting_toolbar_size = 28

setting_panel_left_bottom_size = 300
setting_panel_right_bottom_size = 300
setting_panel_bottom_size = 300
setting_panel_top_size = 205
setting_panel_left_top_size = 300
setting_panel_right_top_size = 300

setting_properties_location = "right"
setting_ground_editor_location = "right_secondary"
setting_template_editor_location = "right_secondary"
setting_timeline_location = "bottom"
setting_timeline_editor_location = "right"
setting_frame_editor_location = "right_secondary"
setting_frame_editor_color_advanced = false
setting_settings_location = "right_secondary"

setting_view_split = 0.5

setting_view_main_overlays = true
setting_view_main_aspect_ratio = false
setting_view_main_grid = false
setting_view_main_gizmos = true
setting_view_main_fog = true
setting_view_main_effects = true
setting_view_main_particles = true
setting_view_main_location = "full"

setting_view_second_show = false
setting_view_second_overlays = true
setting_view_second_aspect_ratio = true
setting_view_second_grid = false
setting_view_second_gizmos = false
setting_view_second_fog = true
setting_view_second_effects = true
setting_view_second_particles = true
setting_view_second_location = "right_bottom"
setting_view_second_width = 440
setting_view_second_height = 280

setting_modelbench_popup_hidden = false

setting_move_speed = 1
setting_look_sensitivity = 1
setting_fast_modifier = 3
setting_slow_modifier = 0.25

setting_bend_style = "realistic"
setting_scenery_remove_edges = false
setting_liquid_animation = true
setting_noisy_grass_water = false
setting_remove_waterlogged_water = false
setting_texture_filtering = true
setting_transparent_block_texture_filtering = false
setting_texture_filtering_level = 1
setting_block_brightness = 0.75
setting_block_glow = true
setting_block_glow_threshold = 0.75
setting_light_bleeding = true

setting_render_samples = 16
setting_render_dof_quality = 3

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
setting_render_shadows_sun_colored = false

setting_render_indirect = true
setting_render_indirect_quality = 0
setting_render_indirect_blur_passes = 2
setting_render_indirect_strength = 1.5
setting_render_indirect_range = 256
setting_render_indirect_scatter = 1

setting_render_glow = true
setting_render_glow_radius = 1
setting_render_glow_intensity = 1
setting_render_glow_falloff = false
setting_render_glow_falloff_radius = 2
setting_render_glow_falloff_intensity = 1

setting_render_aa = true
setting_render_aa_power = 1

setting_render_watermark = trial_version
setting_render_watermark_image = spr_watermark
setting_render_watermark_filename = ""
setting_render_watermark_anchor_x = "right"
setting_render_watermark_anchor_y = "bottom"
setting_render_watermark_scale = 1
setting_render_watermark_alpha = 1

setting_export_movie_format = "mp4"
setting_export_movie_frame_rate = 30
setting_export_movie_bit_rate = 2500000
setting_export_movie_include_audio = true
setting_export_movie_remove_background = false
setting_export_movie_include_hidden = false
setting_export_movie_high_quality = true

setting_export_image_remove_background = false
setting_export_image_include_hidden = false
setting_export_image_high_quality = true

// Viewport
setting_snap = false
setting_snap_absolute = true
setting_snap_size_position = 1
setting_snap_size_rotation = 15
setting_snap_size_scale = 1
setting_tool = e_view_tool.SELECT

// New UI settings
setting_reduced_motion = false
setting_wind_enable = true

settings_load()
languages_load()
interface_update()

texture_set_mipmap_level(setting_texture_filtering_level)