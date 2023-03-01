/// tab_control_loading([height])
/// @arg [height]

function tab_control_loading()
{
	var height = 8;
	
	if (argument_count > 0)
		height = argument[0]
	
	tab_control(24 + height)
}
