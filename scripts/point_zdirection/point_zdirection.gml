/// point_zdirection(x1, y1, z1, x2, y2, z2)
/// @arg x1
/// @arg x1
/// @arg z1
/// @arg x2
/// @arg y2
/// @arg z2
/// @desc http://gmc.yoyogames.com/index.php?showtopic=166489

var x1, y1, z1, x2, y2, z2;
x1 = argument0
y1 = argument1
z1 = argument2
x2 = argument3
y2 = argument4
z2 = argument5

if (x1 = x2 && y1 = y2)
{
    if (z1 > z2)
        return -90
    else
        return 90
}

return radtodeg(arctan((z2 - z1) / sqrt(max(0.001, sqr(x2 - x1) + sqr(y2 - y1)))))
