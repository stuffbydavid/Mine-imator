function env_sky_update()
{
	if (!env_fog_color_custom) // Fog color
	{
		var biome, nextbiome, biomefog, nextfog, fogstart, fogend;
		biome = find_biome(env_biome)
		nextbiome = biome
		if (env_biome_mix > 0)
			nextbiome = find_biome(env_biome_next)
		
		biomefog = false
		nextfog = false
		
		if (biome != null)
			biomefog = biome.fog_enabled
		if (nextbiome != null)
			nextfog = nextbiome.fog_enabled

		env_fog_color_final = env_sky_color_final
		
		if (env_dimension = "overworld")
		{
			fogstart = biomefog ? merge_color(biome.fog_color, env_night_sky_color, env_night_alpha) : env_sky_color_final
			fogend = nextfog ? merge_color(nextbiome.fog_color, env_night_sky_color, env_night_alpha) : env_sky_color_final
			env_fog_color_final = merge_color(fogstart, fogend, env_biome_mix)
		}
			
		if (!env_background_image_show)
		{
			env_fog_color_final = merge_color(env_fog_color_final, merge_color(env_fog_color_final, 0, 0.95), env_night_alpha)
			env_fog_color_final = merge_color(env_fog_color_final, c_fog_bright, (1 - env_night_alpha) * 0.470588)
			env_fog_color_final = merge_color(env_fog_color_final, c_fog_night, env_night_alpha)
			
			if (env_twilight)
			{
				var camxyangle, p;
				camxyangle = point_direction(cam_from[X], cam_from[Y], cam_to[X], cam_to[Y]) - env_sky_rotation
				
				// Sunset
				p = clamp(0, 1 - abs(angle_difference_fix(camxyangle, 270)) / 180, 1)
				env_fog_color_final = merge_color(env_fog_color_final, merge_color(c_sunset_start, c_sunset_end, env_sunset_alpha), env_sunset_alpha * p)
				
				// Sunrise
				p = clamp(0, 1 - abs(angle_difference_fix(camxyangle, 90)) / 180, 1)
				env_fog_color_final = merge_color(env_fog_color_final, merge_color(c_sunset_start, c_sunset_end, env_sunrise_alpha), env_sunrise_alpha * p)
			}
		}
		
		if (env_dimension != "overworld")
		{
			fogstart = biomefog ? biome.fog_color : env_fog_color_final
			fogend = nextfog ? nextbiome.fog_color : env_fog_color_final
			env_fog_color_final = merge_color(fogstart, fogend, env_biome_mix)
		}
	}
	
	if (env_fog_custom_object_color)
		env_fog_object_color_final = env_fog_object_color
	else
		env_fog_object_color_final = env_fog_color_final
	
	// Clouds
	var alphay;
	if (env_sky_clouds_mode = "faded")
		alphay = percent(cam_from[Z], env_sky_clouds_offset_z, env_sky_clouds_offset_z - 250)
	else
		alphay = 1
	
	env_clouds_alpha = env_sky_clouds_mode = "faded" ? (1 - min(env_night_alpha, 0.95)) * alphay : 0.8 //(.8 - min(env_night_alpha, 0.75) * alphay)
	env_sky_clouds_final = merge_color(env_sky_clouds_color, env_night_sky_clouds_color, env_night_alpha)
	env_sky_clouds_vbuffer_pos = []
	
	var size, offset, xo, yo, num, xx, i;
	size = env_sky_clouds_size_xy * 256
	offset = ((env_sky_clouds_speed * (env_time * 0.25 + env_sky_time * 100) + env_sky_clouds_offset_y) mod size)
	xo = (cam_from[X] div size) * size
	yo = (cam_from[Y] div size) * size + offset
	num = (ceil(env_fog_distance / size) + 1) * size
	xx = -num
	i = 0
	
	while (xx < num)
	{
		var yy = -num;
		while (yy < num)
		{
			env_sky_clouds_vbuffer_pos[i] = point3D(xx + xo, yy + yo, env_sky_clouds_offset_z)
			i++
			yy += size
		}
		xx += size
	}
}
