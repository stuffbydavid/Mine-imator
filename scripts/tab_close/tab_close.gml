/// tab_close(tab)
/// @arg tab

var tab, panel;
tab = argument0
panel = tab.panel

if (!tab.show)
	return 0

if (tab = settings)
	settings_save()

panel_tab_list_remove(panel, tab)
tab.show = false
tab_move = null
