function tab_control(height)
{
	tab_control_h = height
	
	if (tab_columns)
	{
		dw = (tab_columns_width - ((tab_columns_count - 1) * 8)) / tab_columns_count
		dx = tab_columns_start_x + ceil(dw * (tab_columns_index)) + (8 * tab_columns_index)
	}
}
