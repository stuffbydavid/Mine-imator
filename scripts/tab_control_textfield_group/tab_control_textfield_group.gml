/// tab_control_textfield_group([label])
/// @arg [label]

function tab_control_textfield_group()
{
	var label, height;
	
	if (argument_count > 0)
		label = argument[0]
	else
		label = true
	
	// Update draw_textfield_group when adjusting width
	height = (dw < 225) ? (24 * textfield_amount) : 24
	
	tab_control(height + ((label_height + 8) * label))
}
