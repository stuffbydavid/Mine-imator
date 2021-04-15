/// textfield_group_add(name, value, default, script, axis, textbox, [icon, [multiplier, [min, max, [caption]]]])
/// @arg name
/// @arg value
/// @arg default
/// @arg script
/// @arg axis
/// @arg textbox
/// @arg [icon
/// @arg [multiplier
/// @arg [min
/// @arg max
/// @arg [caption]]]]

textfield_name = array_add(textfield_name, argument[0])
textfield_value = array_add(textfield_value, argument[1])
textfield_default = array_add(textfield_default, argument[2])
textfield_script = array_add(textfield_script, argument[3])
textfield_axis = array_add(textfield_axis, argument[4])
textfield_textbox = array_add(textfield_textbox, argument[5])

if (argument_count > 6)
	textfield_icon = array_add(textfield_icon, argument[6])
else
	textfield_icon = array_add(textfield_icon, null)

if (argument_count > 7)
	textfield_mul = array_add(textfield_mul, argument[7])
else
	textfield_mul = array_add(textfield_mul, null)

if (argument_count > 8)
{
	textfield_min = array_add(textfield_min, argument[8])
	textfield_max = array_add(textfield_max, argument[9])
}

if (argument_count > 10)
	textfield_caption = array_add(textfield_caption, argument[10])
else
	textfield_caption = array_add(textfield_caption, null)

textfield_amount = array_length_1d(textfield_name)
