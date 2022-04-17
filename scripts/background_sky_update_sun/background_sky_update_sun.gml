/// background_sky_update_sun()

function background_sky_update_sun()
{
	var range = world_size/8;
	
	background_light_data[0] = lengthdir_x(range, background_sky_rotation - 90) * lengthdir_x(1, background_sky_time + 90)
	background_light_data[1] = lengthdir_y(range, background_sky_rotation - 90) * lengthdir_x(1, background_sky_time + 90)
	background_light_data[2] = lengthdir_z(range, background_sky_time + 90)
	
	if (mod_fix(background_sky_time, 360) = 0)
		background_light_data[0] += 0.1
	
	background_sun_direction = vec3_normalize([background_light_data[0], background_light_data[1], background_light_data[2]])
	
	background_light_data[3] = range / 2
	background_light_data[4] = (color_get_red(background_sunlight_color_final) / 255) * (1 + background_sunlight_strength)
	background_light_data[5] = (color_get_green(background_sunlight_color_final) / 255) * (1 + background_sunlight_strength)
	background_light_data[6] = (color_get_blue(background_sunlight_color_final) / 255) * (1 + background_sunlight_strength)
	background_light_data[7] = range * 2
}
