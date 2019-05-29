/// project_reset()

log("Resetting project")

project_reset_backup()
history_clear()

temp_edit = null
res_edit = null
tl_edit = null
tl_edit_amount = 0

lib_preview.update = true
res_preview.update = true

project_file = ""
project_folder = ""
project_changed = false
project_name = ""
project_author = ""
project_description = ""
project_video_width = 1280
project_video_height = 720
project_video_template = find_videotemplate(project_video_width, project_video_height)
project_video_keep_aspect_ratio = true
project_tempo = 24

camera_work_reset()

log("Destroying instances")

with (obj_template)
	instance_destroy()
	
with (obj_timeline)
	instance_destroy()
	
with (obj_resource)
	if (id != mc_res)
		instance_destroy()
		
with (obj_keyframe)
	instance_destroy()

with (mc_res)
	count = 0

background_image_show = false
background_image = null
background_image_type = "image"
background_image_stretch = true
background_image_box_mapped = false

background_sky_sun_tex = mc_res
background_sky_sun_tex.count++
background_sky_moon_tex = mc_res
background_sky_moon_tex.count++
background_sky_moon_phase = 0

background_sky_time = -45
background_sky_rotation = 0
background_sunlight_range = 2000
background_sunlight_follow = false
background_sunlight_strength = 0
background_desaturate_night = false
background_desaturate_night_amount = 0

background_sky_clouds_show = true
background_sky_clouds_update = false
background_sky_clouds_tex = mc_res
background_sky_clouds_tex.count++
background_sky_clouds_flat = false
background_sky_clouds_story_mode = false
background_sky_clouds_speed = 1
background_sky_clouds_z = 1000
background_sky_clouds_size = 192
background_sky_clouds_height = 64
background_sky_clouds_offset = 0
background_sky_update_clouds()

background_ground_show = true
background_ground_tex = mc_res
background_ground_tex.count++
background_ground_name = default_ground
background_ground_slot = ds_list_find_index(mc_assets.block_texture_list, background_ground_name)
background_ground_update_texture()

background_biome = biome_list[|2]
background_foliage_color = c_plains_biome_foliage
background_grass_color = c_plains_biome_grass
background_water_color = c_plains_biome_water

instance_activate_object(obj_biome)
with (obj_biome)
{
	if (biome_base = null)
		selected_variant = 0
}
instance_deactivate_object(obj_biome)

with (mc_res)
	res_update_colors()

background_sky_color = c_sky
background_sky_clouds_color = c_clouds
background_sunlight_color = c_sunlight
background_ambient_color = c_ambient
background_night_color = c_night

background_fog_show = true
background_fog_sky = true
background_fog_color_custom = 0
background_fog_color = c_sky
background_fog_object_color_custom = 0
background_fog_object_color = c_sky
background_fog_distance = 10000
background_fog_size = 2000
background_fog_height = 1250

background_wind = true
background_wind_speed = 0.1
background_wind_strength = 0.5

background_opaque_leaves = false
background_texture_animation_speed = 0.25

background_sunlight_color_final = c_black
background_ambient_color_final = c_black
background_fog_color_final = c_black
background_night_alpha = 0
background_sunset_alpha = 0
background_sunrise_alpha = 0

timeline.hor_scroll.value = 0
timeline.ver_scroll.value = 0

action_toolbar_play_break()
timeline_repeat = false
timeline_marker = 0
timeline_marker_previous = 0
timeline_length = 0
timeline_zoom = 16
timeline_zoom_goal = 16
timeline_camera = null
copy_kf_amount = 0

ds_list_clear(tree_list)
ds_list_clear(tree_visible_list)
app_update_tl_edit()

for (var v = 0; v < e_value.amount; v++)
	value_default[v] = tl_value_default(v)

log("Project resetted")
