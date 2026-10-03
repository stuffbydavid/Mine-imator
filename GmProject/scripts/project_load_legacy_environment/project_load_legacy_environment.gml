function project_load_legacy_environment()
{
	env_loaded = true
	
	env_background_image_show = buffer_read_byte()
	env_background_image = buffer_read_int()
	if (env_background_image = 0)
		env_background_image = null
	var imagetype = [ "image", "sphere", "box" ];
	env_background_image_type = imagetype[buffer_read_byte()]
	env_background_image_stretch = buffer_read_byte()
	if (load_format >= e_project.FORMAT_100_DEBUG)
		env_background_image_box_mapped = buffer_read_byte()
	
	env_sky_time = buffer_read_double()
	env_sky_clouds_show = buffer_read_byte()
	
	var flat = buffer_read_byte();
	env_sky_clouds_mode = (flat ? "flat" : "faded")
	env_sky_clouds_speed = buffer_read_double()
	
	env_ground_show = buffer_read_byte()
	env_ground_legacy_name = legacy_block_100_texture_list[|buffer_read_int()]
	var newslot = minecraft_assets_block_texture_picker_slot_find(env_ground_legacy_name);
	if (newslot >= 0)
		env_ground_slot = newslot
	env_ground_tex = project_load_legacy_save_id()
	env_ground_tex_material = "default"
	env_ground_tex_normal = "default"
	
	env_biome = biome_list[|buffer_read_byte()].name
	
	env_sky_color = buffer_read_int()
	env_sky_clouds_color = buffer_read_int()
	env_sunlight_color = buffer_read_int()
	env_ambient_color = buffer_read_int()
	env_night_color = buffer_read_int()
	
	env_fog_show = buffer_read_byte()
	if (load_format >= e_project.FORMAT_100_DEBUG)
		env_fog_sky = buffer_read_byte()
	env_fog_color_custom = buffer_read_byte()
	env_fog_color = buffer_read_int()
	env_fog_distance = buffer_read_int()
	env_fog_size = buffer_read_int()
	if (load_format >= e_project.FORMAT_100_DEBUG)
		env_fog_height = buffer_read_int()
	
	env_wind = buffer_read_byte()
	env_wind_speed = buffer_read_double()
	env_wind_strength = buffer_read_double()
	
	/*env_opaque_leaves =*/ buffer_read_byte()
	env_texture_animation_speed = buffer_read_double()
	
	/*env_sunlight_range =*/ buffer_read_int()
	
	if (load_format >= e_project.FORMAT_105)
		/*env_sunlight_follow =*/ buffer_read_byte()
	
	if (load_format >= e_project.FORMAT_100_DEMO_4)
	{
		env_sky_sun_tex = project_load_legacy_save_id()
		
		env_sky_moon_tex = project_load_legacy_save_id()
		env_sky_moon_phase = buffer_read_int()
		
		env_sky_rotation = buffer_read_double()
		
		env_sky_clouds_tex = project_load_legacy_save_id()
		env_sky_clouds_offset_z = buffer_read_double()
		env_sky_clouds_size_xy = buffer_read_double()
		env_sky_clouds_size_z = buffer_read_double()
		
		//if (app.env_sky_clouds_tex = "default")
		//	app.env_sky_clouds_size_xy *= 8
	}
	
	if (load_format >= e_project.FORMAT_CB_100)
	{
		var custombiome = buffer_read_byte();
		if (custombiome)
			env_biome = biome_list[| 0].name
		
		env_foliage_color = buffer_read_int()
		env_grass_color = env_foliage_color
	}
}
