function env_sky_update_sun()
{
	var range = project_render_distance / 8;
	
	env_light_data[0] = lengthdir_x(range, env_sky_rotation - 90) * lengthdir_x(1, env_sky_time - 90)
	env_light_data[1] = lengthdir_y(range, env_sky_rotation - 90) * lengthdir_x(1, env_sky_time - 90)
	env_light_data[2] = lengthdir_z(range, env_sky_time + 90)
	
	if (mod_fix(env_sky_time, 360) = 0)
		env_light_data[0] += 0.1
	
	env_sun_direction = vec3_normalize([ env_light_data[0], env_light_data[1], env_light_data[2] ])
	
	env_light_data[3] = range / 2
	env_light_data[4] = (color_get_red(env_sunlight_color_final) / 255) * env_sunlight_strength
	env_light_data[5] = (color_get_green(env_sunlight_color_final) / 255) * env_sunlight_strength
	env_light_data[6] = (color_get_blue(env_sunlight_color_final) / 255) * env_sunlight_strength
	env_light_data[7] = range * 2
}
