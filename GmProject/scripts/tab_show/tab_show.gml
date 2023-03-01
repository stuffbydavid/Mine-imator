/// tab_show(tab)
/// @arg tab

function tab_show(tab)
{
	var panel;
	panel = tab.panel
	
	if (tab.show)
		return 0
	
	panel_tab_list_add(panel, panel.tab_list_amount, tab)
	tab.show = true
}
