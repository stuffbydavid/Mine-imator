/// background_sky_night_alpha()
/// @desc 

function background_sky_night_alpha()
{
	return smoothstep(percent(1 - max(0, vec3_dot(background_sun_direction, vec3(0, 0, 1))), .85, 1))
}
