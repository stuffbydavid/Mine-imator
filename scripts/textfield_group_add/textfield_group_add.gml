/// textfield_group_add(name, value, default, script, axis, textbox, [icon])
/// @arg name
/// @arg value
/// @arg default
/// @arg script
/// @arg axis
/// @arg textbox
/// @arg [icon]

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

textfield_amount = array_length_1d(textfield_name)
