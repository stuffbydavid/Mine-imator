function tab_next(padding = true)
{
	if (tab_collapse)
	{
		dx -= 16
		dw += 16
		
		tab_collapse = false
	}
	
	if (tab_columns)
	{
		tab_columns_index = mod_fix(tab_columns_index + 1, tab_columns_count)
		
		if (tab_columns_index != 0)
			return 0
		
		dx = tab_columns_start_x
	}
	
	dy += tab_control_h + (8 * padding)
}
