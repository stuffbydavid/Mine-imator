/// background_sky_rise_set_alpha(rise)
/// @arg rise

function background_sky_rise_set_alpha(rise)
{
	var t, d, a;
	t = mod_fix(background_sky_time, 360)
	d = percent(vec3_dot(background_sun_direction, vec3(0, 0, 1)), -0.175, 0.325)
	
	if (d > 0.5)
		a = percent(d, 1, 0.5)
	else
		a = percent(d, 0, .5)
	
	if ((rise && t < 180) || (!rise && t > 180))
		a = 0
	
	return smoothstep(a)
}
