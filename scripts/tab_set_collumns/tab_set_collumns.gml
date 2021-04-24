/// tab_set_collumns(enable, [collumns])
/// @arg enable
/// @arg [collumns]

function tab_set_collumns()
{
	tab_collumns = argument[0]
	
	if (tab_collumns = false)
	{
		dw = tab_collumns_width
		
		if (tab_collumns_index != 0)
			tab_next()
		
		dx = dx_start
		
		return 0
	}
	
	if (argument_count > 1)
		tab_collumns_count = argument[1]
	else
		tab_collumns_count = 2
	
	tab_collumns_index = 0
	tab_collumns_width = dw
}
