/// point_line_distance(lx1, ly1, lx2, ly2, px, py)
/// @arg lx1
/// @arg ly1
/// @arg lx2
/// @arg ly2
/// @arg px
/// @arg py

var x0, y0, x1, y1, x2, y2, x3, y3, cx, cy, t;
x1 = argument0;
y1 = argument1;
x2 = argument2;
y2 = argument3;
x3 = argument4;
y3 = argument5;
cx = x2 - x1;
cy = y2 - y1;

if (cx == 0 && cy == 0)
{
    x0 = x1;
    y0 = y1;
}
else
{
    t = clamp(((x3 - x1) * cx + (y3 - y1) * cy) / (cx * cx + cy * cy), 0, 1);
    x0 = x1 + t * cx;
    y0 = y1 + t * cy;
}

return point_distance(x3, y3, x0, y0);
