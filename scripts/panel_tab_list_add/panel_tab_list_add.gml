/// panel_tab_list_add(panel, position, tab)
/// @arg panel
/// @arg position
/// @arg tab

function panel_tab_list_add(panel, pos, tab)
{
	// Push up
	for (var t = panel.tab_list_amount; t > pos; t--)
		panel.tab_list[t] = panel.tab_list[t - 1]
	
	// Insert
	panel.tab_list[pos] = tab
	panel.tab_list_amount++
	tab.panel = panel
	tab.panel_last = panel
	
	// Select
	panel.tab_selected = pos
}
