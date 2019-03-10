/// background_sky_rise_set_alpha(rise)
/// @arg rise

var t, a, x1, x2, x3;

if (argument0)
{
	x1 = 360 - 115
	x2 = 360 - 85 // Most intense
	x3 = 360 - 75
}
else
{
	x1 = 75
	x2 = 85 // Most intense
	x3 = 115
}

t = mod_fix(background_sky_time, 360)

a = 0
if (t >= x1 && t < x2)
	a = percent(t, x1, x2)
if (t >= x2 && t < x3)
	a = 1-percent(t, x2, x3)

return a
