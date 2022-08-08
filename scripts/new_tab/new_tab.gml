/// new_tab(location, show, [header, [window]])
/// @arg location
/// @arg show
/// @arg [header
/// @arg [window]]
/// @desc Creates a new tab and sets its parameters.

function new_tab(location, show, header = null, window = e_window.MAIN)
{
	var tab = new_obj(obj_tab);
	
	tab.panel = panel_map[?argument[0]]
	tab.panel_last = tab.panel
	tab.show = argument[1]
	tab.closeable = !tab.show
	tab.scroll = new_obj(obj_scrollbar)
	tab.movable = true
	tab.header_script = header
	tab.window = window
	
	if (tab.show && !window_exists(window))
		panel_tab_list_add(tab.panel, tab.panel.tab_list_amount, tab)
	
	return tab
}
