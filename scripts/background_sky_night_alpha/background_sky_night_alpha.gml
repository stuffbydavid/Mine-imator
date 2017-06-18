/// background_sky_night_alpha()

var t, a, x1, x2, x3, x4;
x1 = 80
x2 = 110
x3 = 180 + 60
x4 = 180 + 110

t = mod_fix(background_sky_time, 360)

a = 0
if (t >= x1 && t < x2)
    a = percent(t, x1, x2)
if (t >= x2 && t < x3)
    a = 1
if (t >= x3 && t < x4)
    a = 1-percent(t, x3, x4)

return a
