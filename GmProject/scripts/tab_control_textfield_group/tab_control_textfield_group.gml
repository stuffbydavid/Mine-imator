/// tab_control_textfield_group([label])
/// @arg [label]

function tab_control_textfield_group(label = false, stack = true)
{
	// Update draw_textfield_group when adjusting width
	var height = ((app.panel_compact || window_compact) && stack) ? real(ui_small_height * textfield_amount) : ui_small_height
	
	tab_control(height + ((label_height + 8) * label))
}
