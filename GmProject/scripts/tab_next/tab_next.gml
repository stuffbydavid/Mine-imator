/// tab_next([padding])
/// @arg [padding]

function tab_next(padding = true)
{
	if (tab_collapse)
	{
		dx -= 16
		dw += 16
		
		tab_collapse = false
	}
	
	if (tab_collumns)
	{
		tab_collumns_index = mod_fix(tab_collumns_index + 1, tab_collumns_count)
		
		if (tab_collumns_index != 0)
			return 0
		
		dx = tab_collumns_start_x
	}
	
	dy += tab_control_h + (8 * padding)
}
