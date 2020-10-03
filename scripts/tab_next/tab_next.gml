/// tab_next([padding])
/// @arg [padding]

var padding = true;

if (argument_count > 0)
	padding = argument[0]

if (tab_collapse)
{
	dx = dx_start
	dw = dw_start
	
	tab_collapse = false
}

dy += tab_control_h + (8 * padding)
