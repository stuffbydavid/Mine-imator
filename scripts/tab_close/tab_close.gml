/// tab_close(tab)
/// @arg tab

function tab_close(tab)
{
	var panel;
	panel = tab.panel
	
	if (!tab.show)
		return 0
	
	if (tab = settings)
		settings_save()
	
	panel_tab_list_remove(panel, tab)
	tab.show = false
	tab_move = null
}
