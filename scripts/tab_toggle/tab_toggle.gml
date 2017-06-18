/// tab_toggle(tab)
/// @arg tab

var tab = argument0;

if (tab.show)
	tab_close(tab)
else
	tab_show(tab)
