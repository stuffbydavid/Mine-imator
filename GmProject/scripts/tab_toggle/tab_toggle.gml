/// tab_toggle(tab)
/// @arg tab

function tab_toggle(tab)
{
	if (tab.show)
		tab_close(tab)
	else
		tab_show(tab)
}
