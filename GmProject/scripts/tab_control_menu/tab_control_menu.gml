/// tab_control_menu([size])
/// @arg [size]

function tab_control_menu()
{
	var label = ((window_compact && !app.panel_compact) ? 0 : label_height + 8);
	
	if (argument_count > 0)
		tab_control(label + argument[0])
	else
		tab_control(label + 24)
}
