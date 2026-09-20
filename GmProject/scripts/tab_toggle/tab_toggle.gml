/// tab_toggle(tab, [raise])
/// @arg tab
/// @arg [raise]

function tab_toggle(tab, raise = false)
{
	if (tab.show)
		tab_close(tab)
	else
		tab_show(tab, raise)
}
