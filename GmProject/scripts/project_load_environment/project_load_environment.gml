function project_load_environment(map)
{
	if (!ds_map_valid(map))
		return 0
	
	env_loaded = true
	env_dimension = value_get_string(map[?"dimension"], "overworld")
	
	env_background_image_show = value_get_real(map[?"image_show"], env_background_image_show)
	env_background_image = value_get_save_id(map[?"image"], env_background_image)
	env_background_image_type = value_get_string(map[?"image_type"], env_background_image_type)
	env_background_image_stretch = value_get_real(map[?"image_stretch"], env_background_image_stretch)
	env_background_image_box_mapped = value_get_real(map[?"image_box_mapped"], env_background_image_box_mapped)
	env_background_image_rotation = value_get_real(map[?"image_rotation"], env_background_image_rotation)
	
	env_sky_sun_tex = value_get_save_id(map[?"sky_sun_tex"], env_sky_sun_tex)
	env_sky_sun_angle = value_get_real(map[?"sky_sun_angle"], env_sky_sun_angle)
	env_sky_sun_scale = value_get_real(map[?"sky_sun_scale"], env_sky_sun_scale)
	env_sky_moon_tex = value_get_save_id(map[?"sky_moon_tex"], env_sky_moon_tex)
	env_sky_moon_phase = value_get_real(map[?"sky_moon_phase"], env_sky_moon_phase)
	env_sky_moon_angle = value_get_real(map[?"sky_moon_angle"], env_sky_moon_angle)
	env_sky_moon_scale = value_get_real(map[?"sky_moon_scale"], env_sky_moon_scale)
	
	env_sky_time = value_get_real(map[?"sky_time"], env_sky_time)
	if (load_format < e_project.FORMAT_210)
		env_sky_time *= -1
	env_sky_rotation = value_get_real(map[?"sky_rotation"], env_sky_rotation)
	env_sunlight_strength = value_get_real(map[?"sunlight_strength"], env_sunlight_strength)
	env_sunlight_specular_strength = value_get_real(map[?"sunlight_specular_strength"], env_sunlight_specular_strength)
	
	if (load_format < e_project.FORMAT_200_PRE_5)
		env_sunlight_strength += 1
	
	env_sunlight_angle = value_get_real(map[?"sunlight_angle"], env_sunlight_angle)
	
	env_twilight = value_get_real(map[?"twilight"], env_twilight)
	
	env_sky_clouds_show = value_get_real(map[?"sky_clouds_show"], env_sky_clouds_show)
	env_sky_clouds_mode = value_get_real(map[?"sky_clouds_mode"], env_sky_clouds_mode)
	
	if (load_format < e_project.FORMAT_200_PRE_5)
	{
		var faded, flat;
		faded = false
		flat = false
		
		faded = value_get_real(map[?"sky_clouds_story_mode"], faded)
		flat = value_get_real(map[?"sky_clouds_flat"], flat)
		
		if (faded)
			env_sky_clouds_mode = "faded"
		else if (flat)
			env_sky_clouds_mode = "flat"
	}
	else
		env_sky_clouds_mode = value_get_string(map[?"sky_clouds_mode"], env_sky_clouds_mode)
	
	if (load_format < e_project.FORMAT_200_PRE_5)
	{
		env_sky_clouds_offset_z = value_get_real(map[?"sky_clouds_z"], env_sky_clouds_offset_z)
		env_sky_clouds_size_z = value_get_real(map[?"sky_clouds_height"], env_sky_clouds_size_z)
	}
	else if (load_format < e_project.FORMAT_210)
	{
		env_sky_clouds_offset_z = value_get_real(map[?"sky_clouds_height"], env_sky_clouds_offset_z)
		env_sky_clouds_size_z = value_get_real(map[?"sky_clouds_thickness"], env_sky_clouds_size_z)
	}
	else
	{
		env_sky_clouds_offset_z = value_get_real(map[?"sky_clouds_offset_z"], env_sky_clouds_offset_z)
		env_sky_clouds_size_z = value_get_real(map[?"sky_clouds_size_z"], env_sky_clouds_size_z)
	}
	
	if (load_format < e_project.FORMAT_210)
	{
		env_sky_clouds_size_xy = value_get_real(map[?"sky_clouds_size"], env_sky_clouds_size_xy)
		if (load_format >= e_project.FORMAT_200_PRE_5)
			env_sky_clouds_size_xy /= 8
		env_sky_clouds_offset_y = value_get_real(map[?"sky_clouds_offset"], env_sky_clouds_offset_y)
		env_sky_clouds_offset_y *= -1
	}
	else
	{
		env_sky_clouds_size_xy = value_get_real(map[?"sky_clouds_size_xy"], env_sky_clouds_size_xy)
		env_sky_clouds_offset_y = value_get_real(map[?"sky_clouds_offset_y"], env_sky_clouds_offset_y)
	}
	
	env_sky_clouds_tex = value_get_save_id(map[?"sky_clouds_tex"], env_sky_clouds_tex)
	env_sky_clouds_speed = value_get_real(map[?"sky_clouds_speed"], env_sky_clouds_speed)
	if (load_format < e_project.FORMAT_210)
		env_sky_clouds_speed *= -1
	
	/*
	// Update cloud size
	if (load_format < e_project.FORMAT_200_PRE_5)
	{
		if (app.env_sky_clouds_tex = "default")
			app.env_sky_clouds_size_xy *= 8
	}
	*/
	
	env_ground_show = value_get_real(map[?"ground_show"], env_ground_show)
	env_ground_name = value_get_string(map[?"ground_name"], env_ground_name)
	
	if (load_format < e_project.FORMAT_120_PRE_1)
	{
		env_ground_name = string_replace(env_ground_name, "blocks/", "block/")
		var newname = ds_map_find_key(legacy_block_texture_name_map, env_ground_name);
		if (!is_undefined(newname))
			env_ground_name = newname
	}
	
	env_ground_slot = minecraft_assets_block_texture_picker_slot_find(env_ground_name)
	env_ground_tex = value_get_save_id(map[?"ground_tex"], env_ground_tex)
	env_ground_tex_material = value_get_save_id(map[?"ground_tex_material"], env_ground_tex_material)
	env_ground_tex_normal = value_get_save_id(map[?"ground_tex_normal"], env_ground_tex_normal)
	
	env_biome = value_get_string(map[?"biome"], env_biome)
	
	// Empty biome name bugfix (revert to dimension default)
	if (env_biome = "" || !find_biome(env_biome))
	{
		var defbiome = overworld_biome;
		if (env_dimension = "the_nether")
			defbiome = the_nether_biome
		else if (env_dimension = "the_end")
			defbiome = the_end_biome
		
		if (find_biome(defbiome))
			env_biome = defbiome
		else
			env_biome = biome_list[|1].name
	}
	
	env_sky_color = value_get_color(map[?"sky_color"], env_sky_color)
	env_sky_clouds_color = value_get_color(map[?"sky_clouds_color"], env_sky_clouds_color)
	env_sunlight_color = value_get_color(map[?"sunlight_color"], env_sunlight_color)
	env_ambient_color = value_get_color(map[?"ambient_color"], env_ambient_color)
	env_night_sky_color = value_get_color(map[?"night_sky_color"], env_night_sky_color)
	env_night_sky_clouds_color = value_get_color(map[?"night_sky_clouds_color"], env_night_sky_clouds_color)
	env_night_sky_stars_color = value_get_color(map[?"night_sky_stars_color"], env_night_sky_stars_color)
	env_night_color = value_get_color(map[?"night_color"], env_night_color)
	
	env_water_color = value_get_color(map[?"water_color"], env_water_color)
	env_grass_color = value_get_color(map[?"grass_color"], env_grass_color)
	env_foliage_color = value_get_color(map[?"foliage_color"], env_foliage_color)
	env_dry_foliage_color = value_get_color(map[?"dry_foliage_color"], env_dry_foliage_color)
	env_leaves_oak_color = value_get_color(map[?"leaves_oak_color"], env_leaves_oak_color)
	env_leaves_spruce_color = value_get_color(map[?"leaves_spruce_color"], env_leaves_spruce_color)
	env_leaves_birch_color = value_get_color(map[?"leaves_birch_color"], env_leaves_birch_color)
	env_leaves_jungle_color = value_get_color(map[?"leaves_jungle_color"], env_leaves_jungle_color)
	env_leaves_acacia_color = value_get_color(map[?"leaves_acacia_color"], env_leaves_acacia_color)
	env_leaves_dark_oak_color = value_get_color(map[?"leaves_dark_oak_color"], env_leaves_dark_oak_color)
	env_leaves_mangrove_color = value_get_color(map[?"leaves_mangrove_color"], env_leaves_mangrove_color)
	
	env_fog_show = value_get_real(map[?"fog_show"], env_fog_show)
	env_fog_sky = value_get_real(map[?"fog_sky"], env_fog_sky)
	env_fog_color_custom = value_get_real(map[?"fog_color_custom"], env_fog_color_custom)
	env_fog_color = value_get_color(map[?"fog_color"], env_fog_color)
	env_fog_custom_object_color = value_get_real(map[?"fog_object_color_custom"], env_fog_custom_object_color)
	env_fog_object_color = value_get_color(map[?"fog_object_color"], env_fog_object_color)
	env_fog_distance = value_get_real(map[?"fog_distance"], env_fog_distance)
	env_fog_size = value_get_real(map[?"fog_size"], env_fog_size)
	env_fog_height = value_get_real(map[?"fog_height"], env_fog_height)
	
	env_wind = value_get_real(map[?"wind"], env_wind)
	env_wind_speed = value_get_real(map[?"wind_speed"], env_wind_speed)
	env_wind_strength = value_get_real(map[?"wind_strength"], env_wind_strength)
	env_wind_direction = value_get_real(map[?"wind_direction"], env_wind_direction)
	env_wind_directional_speed = value_get_real(map[?"wind_directional_speed"], env_wind_directional_speed)
	env_wind_directional_strength = value_get_real(map[?"wind_directional_strength"], env_wind_directional_strength)
	
	env_texture_animation_speed = value_get_real(map[?"texture_animation_speed"], env_texture_animation_speed)
	env_brightness = value_get_real(map[?"brightness"], env_brightness)
	
	if (load_format < e_project.FORMAT_CTB_106)
		env_texture_animation_speed *= 3 // 75% for older projects
	else if (load_format < e_project.FORMAT_210)
		env_texture_animation_speed /= 20
}
