/// @arg enable
/// @arg [columns]

function tab_set_columns(enable, columns = 2)
{
	tab_columns = enable
	
	if (!tab_columns)
	{
		dw = tab_columns_width
		
		if (tab_columns_index != 0)
			tab_next()
		
		dx = tab_columns_start_x
		
		return 0
	}
	else
		tab_columns_start_x = dx
	
	tab_columns_count = columns
	
	tab_columns_index = 0
	tab_columns_width = dw
}
