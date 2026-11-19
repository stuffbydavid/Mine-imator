function env_sky_night_alpha()
{
	return smoothstep(percent(1 - max(0, vec3_dot(env_sun_direction, vec3(0, 0, 1))), .85, 1))
}
