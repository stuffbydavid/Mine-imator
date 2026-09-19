/// tab_show(tab, raise)
/// @arg tab

function tab_show(tab, raise = false)
{
	var panel;
	panel = tab.panel
	
	if (!tab.show)
	{
		panel_tab_list_add(panel, panel.tab_list_amount, tab)
		tab.show = true
	}
	
	if (raise)
	{
		for (var i = 0; i < tab.panel.tab_list_amount; i++)
		{
			if (tab.panel.tab_list[i] = tab)
			{
				tab.panel.tab_selected = i
				break
			}
		}
	}
}
