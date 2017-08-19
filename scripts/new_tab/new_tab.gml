/// new_tab(panel, show)
/// @arg panel
/// @arg show
/// @desc Creates a new tab and sets its parameters.

var tab = new(obj_tab);

tab.panel = argument0
tab.show = argument1
tab.closeable = !tab.show
tab.scroll = new(obj_scrollbar)

if (tab.show)
	panel_tab_list_add(tab.panel, tab.panel.tab_list_amount, tab)

return tab
