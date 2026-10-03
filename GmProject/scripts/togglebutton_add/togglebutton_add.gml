/// @arg name
/// @arg icon
/// @arg value
/// @arg active
/// @arg script
/// @arg [axisedit]
/// @arg [text]

function togglebutton_add(name, icon, value, active, script, axisedit = X, text = "")
{
	togglebutton_name = array_add(togglebutton_name, name)
	togglebutton_icon = array_add(togglebutton_icon, icon)
	togglebutton_value = array_add(togglebutton_value, value)
	togglebutton_active = array_add(togglebutton_active, active)
	togglebutton_script = array_add(togglebutton_script, script)
	togglebutton_axis = array_add(togglebutton_axis, axisedit)
	if (text !=	"")
		togglebutton_text = array_add(togglebutton_text, text)
	else
		togglebutton_text = array_add(togglebutton_text, text_get(name))
	
	togglebutton_amount = array_length(togglebutton_name)
}
