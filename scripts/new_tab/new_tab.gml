/// new_tab(location, show, [header])
/// @arg location
/// @arg show
/// @arg [header]
/// @desc Creates a new tab and sets its parameters.

var tab = new(obj_tab);

tab.panel = panel_map[?argument[0]]
tab.show = argument[1]
tab.closeable = !tab.show
tab.scroll = new(obj_scrollbar)
tab.movable = true

if (argument_count > 2)
	tab.header_script = argument[2]
else
	tab.header_script = null

if (tab.show)
	panel_tab_list_add(tab.panel, tab.panel.tab_list_amount, tab)

return tab
