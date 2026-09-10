/// togglebutton_add(name, icon, value, active, script, [axisedit, [text]])
/// @arg name
/// @arg icon
/// @arg value
/// @arg active
/// @arg script
/// @arg [axisedit
/// @arg [text]]

function togglebutton_add()
{
	togglebutton_name = array_add(togglebutton_name, argument[0])
	togglebutton_icon = array_add(togglebutton_icon, argument[1])
	togglebutton_value = array_add(togglebutton_value, argument[2])
	togglebutton_active = array_add(togglebutton_active, argument[3])
	togglebutton_script = array_add(togglebutton_script, argument[4])
	togglebutton_amount = array_length(togglebutton_name)
	
	if (argument_count > 5)
		togglebutton_axis = array_add(togglebutton_axis, argument[5])
	else
		togglebutton_axis = array_add(togglebutton_axis, X)
		
	if (argument_count > 6)
		togglebutton_text = array_add(togglebutton_text, argument[6])
	else
		togglebutton_text = array_add(togglebutton_text, text_get(argument[0]))
}
