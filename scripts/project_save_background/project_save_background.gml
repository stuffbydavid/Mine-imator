/// project_save_background()

json_save_object_start("background")
	
	json_save_var_bool("image_show", background_image_show)
	json_save_var_save_id("image", background_image)
	json_save_var("image_type", background_image_type)
	json_save_var_bool("image_stretch", background_image_stretch)
	json_save_var_bool("image_box_mapped", background_image_box_mapped)
	
	json_save_var_save_id("sky_sun_tex", background_sky_sun_tex)
	json_save_var_save_id("sky_moon_tex", background_sky_moon_tex)
	json_save_var("sky_moon_phase", background_sky_moon_phase)
	
	json_save_var("sky_time", background_sky_time)
	json_save_var("sky_rotation", background_sky_rotation)
	json_save_var("sunlight_range", background_sunlight_range)
	json_save_var_bool("sunlight_follow", background_sunlight_follow)

	json_save_var_bool("sky_clouds_show", background_sky_clouds_show)
	json_save_var_bool("sky_clouds_flat", background_sky_clouds_flat)
	json_save_var_save_id("sky_clouds_tex", background_sky_clouds_tex)
	json_save_var("sky_clouds_speed", background_sky_clouds_speed)
	json_save_var("sky_clouds_z", background_sky_clouds_z)
	json_save_var("sky_clouds_size", background_sky_clouds_size)
	json_save_var("sky_clouds_height", background_sky_clouds_height)
	
	json_save_var_bool("ground_show", background_ground_show)
	json_save_var("ground_name", background_ground_name)
	json_save_var_save_id("ground_tex", background_ground_tex)

	json_save_var("biome", background_biome.name)

	json_save_var_color("sky_color", background_sky_color)
	json_save_var_color("sky_clouds_color", background_sky_clouds_color)
	json_save_var_color("sunlight_color", background_sunlight_color)
	json_save_var_color("ambient_color", background_ambient_color)
	json_save_var_color("night_color", background_night_color)
	
	json_save_var_bool("fog_show", background_fog_show)
	json_save_var_bool("fog_sky", background_fog_sky)
	json_save_var_bool("fog_color_custom", background_fog_color_custom)
	json_save_var_color("fog_color", background_fog_color)
	json_save_var("fog_distance", background_fog_distance)
	json_save_var("fog_size", background_fog_size)
	json_save_var("fog_height", background_fog_height)
	
	json_save_var_bool("wind", background_wind)
	json_save_var("wind_speed", background_wind_speed)
	json_save_var("wind_strength", background_wind_strength)
	
	json_save_var_bool("opaque_leaves", background_opaque_leaves)
	json_save_var("texture_animation_speed", background_texture_animation_speed)

json_save_object_done()