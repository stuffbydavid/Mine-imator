/// project_load_background(map)
/// @arg map

function project_load_background(map)
{
	if (!ds_map_valid(map))
		return 0
	
	background_loaded = true
	
	background_image_show = value_get_real(map[?"image_show"], background_image_show)
	if (background_image != null)
		background_image.count--
	background_image = value_get_save_id(map[?"image"], background_image)
	background_image_type = value_get_string(map[?"image_type"], background_image_type)
	background_image_stretch = value_get_real(map[?"image_stretch"], background_image_stretch)
	background_image_box_mapped = value_get_real(map[?"image_box_mapped"], background_image_box_mapped)
	background_image_rotation = value_get_real(map[?"image_rotation"], background_image_rotation)
	
	background_sky_sun_tex.count--
	background_sky_sun_tex = value_get_save_id(map[?"sky_sun_tex"], background_sky_sun_tex)
	background_sky_moon_tex.count--
	background_sky_moon_tex = value_get_save_id(map[?"sky_moon_tex"], background_sky_moon_tex)
	background_sky_moon_phase = value_get_real(map[?"sky_moon_phase"], background_sky_moon_phase)
	
	background_sky_time = value_get_real(map[?"sky_time"], background_sky_time)
	background_sky_rotation = value_get_real(map[?"sky_rotation"], background_sky_rotation)
	background_sunlight_strength = value_get_real(map[?"sunlight_strength"], background_sunlight_strength)
	
	if (load_format < e_project.FORMAT_200_PRE_5)
		background_sunlight_strength += 1
	
	background_sunlight_angle = value_get_real(map[?"sunlight_angle"], background_sunlight_angle)
	
	background_twilight = value_get_real(map[?"twilight"], background_twilight)
	
	background_sky_clouds_show = value_get_real(map[?"sky_clouds_show"], background_sky_clouds_show)
	background_sky_clouds_mode = value_get_real(map[?"sky_clouds_mode"], background_sky_clouds_mode)
	
	if (load_format < e_project.FORMAT_200_PRE_5)
	{
		var faded, flat;
		faded = false
		flat = false
		
		faded = value_get_real(map[?"sky_clouds_story_mode"], faded)
		flat = value_get_real(map[?"sky_clouds_flat"], flat)
		
		if (faded)
			background_sky_clouds_mode = "faded"
		else if (flat)
			background_sky_clouds_mode = "flat"
		
		background_sky_clouds_height = value_get_real(map[?"sky_clouds_z"], background_sky_clouds_height)
		background_sky_clouds_thickness = value_get_real(map[?"sky_clouds_height"], background_sky_clouds_thickness)
	}
	else
	{
		background_sky_clouds_mode = value_get_string(map[?"sky_clouds_mode"], background_sky_clouds_mode)
		background_sky_clouds_height = value_get_real(map[?"sky_clouds_height"], background_sky_clouds_height)
		background_sky_clouds_thickness = value_get_real(map[?"sky_clouds_thickness"], background_sky_clouds_thickness)
	}
	
	background_sky_clouds_tex.count--
	background_sky_clouds_tex = value_get_save_id(map[?"sky_clouds_tex"], background_sky_clouds_tex)
	background_sky_clouds_size = value_get_real(map[?"sky_clouds_size"], background_sky_clouds_size)
	background_sky_clouds_speed = value_get_real(map[?"sky_clouds_speed"], background_sky_clouds_speed)
	background_sky_clouds_offset = value_get_real(map[?"sky_clouds_offset"], background_sky_clouds_offset)
	
	// Update cloud size
	if (load_format < e_project.FORMAT_200_PRE_5)
	{
		if (app.background_sky_clouds_tex = "default")
			app.background_sky_clouds_size *= 8
	}
	
	background_ground_show = value_get_real(map[?"ground_show"], background_ground_show)
	background_ground_name = value_get_string(map[?"ground_name"], background_ground_name)
	
	if (load_format < e_project.FORMAT_120_PRE_1)
	{
		background_ground_name = string_replace(background_ground_name, "blocks/", "block/")
		var newname = ds_map_find_key(legacy_block_texture_name_map, background_ground_name);
		if (!is_undefined(newname))
			background_ground_name = newname
	}
	
	background_ground_slot = ds_list_find_index(mc_assets.block_texture_list, background_ground_name)
	if (background_ground_slot < 0) // Animated
		background_ground_slot = ds_list_size(mc_assets.block_texture_list) + ds_list_find_index(mc_assets.block_texture_ani_list, background_ground_name)
		
	background_ground_tex.count--
	background_ground_tex = value_get_save_id(map[?"ground_tex"], background_ground_tex)
	
	background_ground_tex_material.count--
	background_ground_tex_material = value_get_save_id(map[?"ground_tex_material"], background_ground_tex_material)
	
	background_ground_tex_normal.count--
	background_ground_tex_normal = value_get_save_id(map[?"ground_tex_normal"], background_ground_tex_normal)
	
	background_biome = value_get_string(map[?"biome"], background_biome)
	
	// Empty biome name bugfix (revert to plains)
	if (background_biome = "")
		background_biome = biome_list[|2].name
	
	background_sky_color = value_get_color(map[?"sky_color"], background_sky_color)
	background_sky_clouds_color = value_get_color(map[?"sky_clouds_color"], background_sky_clouds_color)
	background_sunlight_color = value_get_color(map[?"sunlight_color"], background_sunlight_color)
	background_ambient_color = value_get_color(map[?"ambient_color"], background_ambient_color)
	background_night_color = value_get_color(map[?"night_color"], background_night_color)
	
	background_water_color = value_get_color(map[?"water_color"], background_water_color)
	background_grass_color = value_get_color(map[?"grass_color"], background_grass_color)
	background_foliage_color = value_get_color(map[?"foliage_color"], background_foliage_color)
	background_leaves_oak_color = value_get_color(map[?"leaves_oak_color"], background_leaves_oak_color)
	background_leaves_spruce_color = value_get_color(map[?"leaves_spruce_color"], background_leaves_spruce_color)
	background_leaves_birch_color = value_get_color(map[?"leaves_birch_color"], background_leaves_birch_color)
	background_leaves_jungle_color = value_get_color(map[?"leaves_jungle_color"], background_leaves_jungle_color)
	background_leaves_acacia_color = value_get_color(map[?"leaves_acacia_color"], background_leaves_acacia_color)
	background_leaves_dark_oak_color = value_get_color(map[?"leaves_dark_oak_color"], background_leaves_dark_oak_color)
	background_leaves_mangrove_color = value_get_color(map[?"leaves_mangrove_color"], background_leaves_mangrove_color)
	
	background_fog_show = value_get_real(map[?"fog_show"], background_fog_show)
	background_fog_sky = value_get_real(map[?"fog_sky"], background_fog_sky)
	background_fog_color_custom = value_get_real(map[?"fog_color_custom"], background_fog_color_custom)
	background_fog_color = value_get_color(map[?"fog_color"], background_fog_color)
	background_fog_custom_object_color = value_get_real(map[?"fog_object_color_custom"], background_fog_custom_object_color)
	background_fog_object_color = value_get_color(map[?"fog_object_color"], background_fog_object_color)
	background_fog_distance = value_get_real(map[?"fog_distance"], background_fog_distance)
	background_fog_size = value_get_real(map[?"fog_size"], background_fog_size)
	background_fog_height = value_get_real(map[?"fog_height"], background_fog_height)
	
	background_wind = value_get_real(map[?"wind"], background_wind)
	background_wind_speed = value_get_real(map[?"wind_speed"], background_wind_speed)
	background_wind_strength = value_get_real(map[?"wind_strength"], background_wind_strength)
	background_wind_direction = value_get_real(map[?"wind_direction"], background_wind_direction)
	background_wind_directional_speed = value_get_real(map[?"wind_directional_speed"], background_wind_directional_speed)
	background_wind_directional_strength = value_get_real(map[?"wind_directional_strength"], background_wind_directional_strength)
	
	background_texture_animation_speed = value_get_real(map[?"texture_animation_speed"], background_texture_animation_speed)
}
