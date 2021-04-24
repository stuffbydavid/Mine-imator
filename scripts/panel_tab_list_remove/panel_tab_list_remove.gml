/// panel_tab_list_remove(panel, tab)
/// @arg panel
/// @arg tab

function panel_tab_list_remove(panel, tab)
{
	var pos;
	
	// Find pos
	for (pos = 0; pos < panel.tab_list_amount; pos++)
		if (panel.tab_list[pos] = tab)
			break
	
	// Push down
	panel.tab_list_amount--
	for (var t = pos; t < panel.tab_list_amount; t++)
		panel.tab_list[t] = panel.tab_list[t + 1]
	
	// Select
	panel.tab_selected = min(panel.tab_list_amount - 1, panel.tab_selected)
}
