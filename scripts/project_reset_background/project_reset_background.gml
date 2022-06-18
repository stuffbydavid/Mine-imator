/// project_reset_background()

function project_reset_background()
{
	background_image_show = false
	background_image = null
	background_image_type = "image"
	background_image_stretch = true
	background_image_box_mapped = false
	background_image_rotation = 0
	
	background_sky_sun_tex = mc_res
	background_sky_sun_tex.count++
	background_sky_moon_tex = mc_res
	background_sky_moon_tex.count++
	background_sky_moon_phase = 0
	
	background_sky_time = -45
	background_sky_rotation = 0
	background_sunlight_strength = 1
	background_sunlight_angle = .526
	background_twilight = true
	
	background_sky_clouds_show = true
	background_sky_clouds_update = false
	background_sky_clouds_tex = mc_res
	background_sky_clouds_tex.count++
	background_sky_clouds_mode = "normal"
	background_sky_clouds_speed = 1
	background_sky_clouds_height = 1024
	background_sky_clouds_size = 1536
	background_sky_clouds_thickness = 64
	background_sky_clouds_offset = 0
	background_sky_update_clouds()
	
	background_ground_show = true
	background_ground_tex = mc_res
	background_ground_tex.count++
	background_ground_tex_material = mc_res
	background_ground_tex_material.count++
	background_ground_tex_normal = mc_res
	background_ground_tex_normal.count++
	background_ground_name = default_ground
	background_ground_slot = ds_list_find_index(mc_assets.block_texture_list, background_ground_name)
	background_ground_slot_prev = null
	background_ground_slot_normal = null
	background_ground_slot_material = null
	background_ground_tex_prev = null
	background_ground_tex_material_prev = null
	background_ground_tex_normal_prev = null
	background_ground_update_texture()
	background_ground_update_texture_material()
	background_ground_update_texture_normal()
	
	background_biome = biome_list[|2].name
	background_biome_prev = background_biome
	background_grass_color = c_plains_biome_grass
	background_foliage_color = c_plains_biome_foliage
	background_water_color = c_plains_biome_water
	background_leaves_oak_color = c_plains_biome_foliage
	background_leaves_spruce_color = c_plains_biome_foliage_2
	background_leaves_birch_color = c_plains_biome_foliage_2
	background_leaves_jungle_color = c_plains_biome_foliage
	background_leaves_acacia_color = c_plains_biome_foliage
	background_leaves_dark_oak_color = c_plains_biome_foliage
	background_leaves_mangrove_color = c_plains_biome_foliage
	
	with (mc_res)
		res_update_colors()
	
	background_sky_color = c_sky
	background_sky_clouds_color = c_clouds
	background_sunlight_color = c_sunlight
	background_ambient_color = c_ambient
	background_night_color = c_night
	
	background_fog_show = true
	background_fog_sky = true
	background_fog_color_custom = false
	background_fog_color = c_sky
	background_fog_distance = 10000
	background_fog_size = 2000
	background_fog_height = 1250
	
	background_wind = true
	background_wind_speed = 0.1
	background_wind_strength = 0.5
	background_wind_direction = 45
	background_wind_directional_speed = 0.2
	background_wind_directional_strength = 1.5
	
	background_texture_animation_speed = 0.25
	
	background_sunlight_color_final = c_black
	background_ambient_color_final = c_black
	background_fog_color_final = c_black
	background_night_alpha = 0
	background_sunset_alpha = 0
	background_sunrise_alpha = 0
	background_sky_color_final = c_black
	background_clouds_alpha = 0
	background_sky_clouds_final = c_black
	
	background_time = 0
	background_time_prev = 0
}