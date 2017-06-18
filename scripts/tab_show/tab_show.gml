/// tab_show(tab)
/// @arg tab

var tab, panel;
tab = argument0
panel = tab.panel

if (tab.show)
	return 0
	
panel_tab_list_add(panel, panel.tab_list_amount, tab)
tab.show = true
