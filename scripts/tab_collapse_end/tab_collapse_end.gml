/// tab_collapse_end([divider])
/// @arg [divider]

var divider = (argument_count > 0 ? argument[0] : true);

dx -= 12
dw += 12
collapse_ani = 1

if (divider)
{
	draw_divide(dx, dy, dw)
	dy += 8
}
