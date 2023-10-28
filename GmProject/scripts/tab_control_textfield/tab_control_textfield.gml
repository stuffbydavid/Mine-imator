/// tab_control_textfield([toplabel, [size]])
/// @arg [toplabel
/// @arg [size]]

function tab_control_textfield(toplabel = true, size = 24)
{
	tab_control(size + ((label_height + 8) * toplabel))
}
