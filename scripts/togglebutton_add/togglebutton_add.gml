/// togglebutton_add(name, icon, value, active, script, [axisedit])
/// @arg name
/// @arg icon
/// @arg value
/// @arg active
/// @arg script
/// @arg [axisedit]

togglebutton_name = array_add(togglebutton_name, argument[0])
togglebutton_icon = array_add(togglebutton_icon, argument[1])
togglebutton_value = array_add(togglebutton_value, argument[2])
togglebutton_active = array_add(togglebutton_active, argument[3])
togglebutton_script = array_add(togglebutton_script, argument[4])
togglebutton_amount = array_length_1d(togglebutton_name)

if (argument_count > 5)
	togglebutton_axis = array_add(togglebutton_axis, argument[5])
else
	togglebutton_axis = array_add(togglebutton_axis, X)