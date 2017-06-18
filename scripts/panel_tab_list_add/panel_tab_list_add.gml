/// panel_tab_list_add(panel, position, tab)
/// @arg panel
/// @arg position
/// @arg tab

var panel, pos, tab;
panel = argument0
pos = argument1
tab = argument2

// Push up
for (var t = panel.tab_list_amount; t > pos; t--)
    panel.tab_list[t] = panel.tab_list[t - 1]

// Insert
panel.tab_list[pos] = tab
panel.tab_list_amount++
tab.panel = panel

// Select
panel.tab_selected = pos
