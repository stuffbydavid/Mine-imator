/// tab_next([padding])
/// @arg [padding]

function tab_next()
{
	var padding = (argument_count > 0 ? argument[0] : true);
	
	if (tab_collapse)
	{
		dx = dx_start
		dw = dw_start
		
		tab_collapse = false
	}
	
	if (tab_collumns)
	{
		tab_collumns_index = mod_fix(tab_collumns_index + 1, tab_collumns_count)
		
		if (tab_collumns_index != 0)
			return 0
		
		dx = dx_start
	}
	
	dy += tab_control_h + (8 * padding)
}
