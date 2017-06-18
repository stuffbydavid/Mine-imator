/// background_sky_rise_set_alpha(rise)

var t, a, x1, x2, x3;
x1 = 70 + 180 * argument0
x2 = 90 + 180 * argument0  // Most intense
x3 = 110 + 180 * argument0

t = mod_fix(background_sky_time, 360)

a = 0
if (t >= x1 && t < x2)
    a = percent(t, x1, x2)
if (t >= x2 && t < x3)
    a = 1-percent(t, x2, x3)

return a
