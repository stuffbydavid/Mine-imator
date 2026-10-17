function project_reset_environment()
{
	env_dimension = "overworld"
	
	env_background_image_show = false
	env_background_image = null
	env_background_image_type = "image"
	env_background_image_stretch = true
	env_background_image_box_mapped = false
	env_background_image_rotation = 0
	
	env_sky_sun_tex = project_pack_res
	env_sky_sun_angle = 0
	env_sky_sun_scale = 1
	env_sky_moon_tex = project_pack_res
	env_sky_moon_phase = 0
	env_sky_moon_angle = 0
	env_sky_moon_scale = 1
	
	env_sky_time = 45
	env_sky_rotation = -45
	env_sunlight_strength = 1
	env_sunlight_specular_strength = 1
	env_sunlight_angle = .526
	env_twilight = true
	
	env_sky_clouds_show = true
	env_sky_clouds_tex = project_pack_res
	env_sky_clouds_mode = "normal"
	env_sky_clouds_speed = 1
	env_sky_clouds_offset_y = 0
	env_sky_clouds_offset_z = 1024
	env_sky_clouds_size_xy = 192
	env_sky_clouds_size_z = 64
	env_sky_update_clouds()
	
	env_ground_show = true
	env_ground_tex = project_pack_res
	env_ground_tex_material = project_pack_res
	env_ground_tex_normal = project_pack_res
	env_ground_name = overworld_ground
	env_ground_slot = minecraft_assets_block_texture_picker_slot_find(env_ground_name)
	env_ground_slot_prev = null
	env_ground_slot_normal = null
	env_ground_slot_material = null
	env_ground_tex_prev = null
	env_ground_tex_material_prev = null
	env_ground_tex_normal_prev = null
	env_ground_update_texture()
	env_ground_update_texture_material()
	env_ground_update_texture_normal()
	
	if (find_biome(overworld_biome))
		env_biome = overworld_biome
	else
		env_biome = biome_list[|1].name
	
	env_biome_prev = env_biome
	env_biome_next = env_biome
	env_biome_mix = 0
	env_color_list = [
		c_plains_biome_grass,
		c_plains_biome_foliage,
		c_plains_biome_dry_foliage,
		c_plains_biome_water,
		c_plains_biome_foliage,
		c_plains_biome_foliage_2,
		c_plains_biome_foliage_2,
		c_plains_biome_foliage,
		c_plains_biome_foliage,
		c_plains_biome_foliage,
		c_plains_biome_foliage
	]
	
	with (mc_res)
		res_update_colors()
	
	env_sky_color = c_sky_overworld
	env_sky_clouds_color = c_clouds
	env_sunlight_color = c_sunlight
	env_ambient_color = c_ambient
	env_night_sky_color = c_night_sky
	env_night_sky_clouds_color = c_night_clouds
	env_night_sky_stars_color = c_stars
	env_night_color = c_night
	
	env_fog_show = true
	env_fog_sky = true
	env_fog_color_custom = false
	env_fog_color = c_sky_overworld
	env_fog_custom_object_color = false
	env_fog_object_color = c_sky_overworld
	env_fog_distance = fog_far
	env_fog_size = fog_size
	env_fog_height = fog_height
	
	env_wind = true
	env_wind_speed = 0.1
	env_wind_strength = 0.5
	env_wind_direction = 45
	env_wind_directional_speed = 0.2
	env_wind_directional_strength = 1.5
	
	env_texture_animation_speed = 1
	env_brightness = 1
	
	env_sunlight_color_final = c_black
	env_ambient_color_final = c_black
	env_fog_color_final = c_black
	env_fog_object_color_final = c_black
	env_night_alpha = 0
	env_sunset_alpha = 0
	env_sunrise_alpha = 0
	env_sky_color_final = c_black
	env_clouds_alpha = 0
	env_sky_clouds_final = c_black
	
	env_time = 0
	env_time_prev = 0
}
