/// new_tab(location, show, [header, [window]])
/// @arg location
/// @arg show
/// @arg [header
/// @arg [window]]
/// @desc Creates a new tab and sets its parameters.

function new_tab(location, show, header = null, window = e_window.MAIN)
{
	var tab = new_obj(obj_tab);
	
	// Pre-Inventory location names
	location = string_replace(location, "_top", "")
	location = string_replace(location, "_bottom", "_secondary")
	if (!ds_map_exists(panel_map, location))
		location = "right"
	
	tab.panel = panel_map[?location]
	tab.panel_last = tab.panel
	tab.show = show
	tab.closeable = !tab.show
	tab.scroll = new_obj(obj_scrollbar)
	tab.movable = true
	tab.header_script = header
	tab.window = window
	
	if (tab.show && !window_exists(window))
		panel_tab_list_add(tab.panel, tab.panel.tab_list_amount, tab)
	
	return tab
}
