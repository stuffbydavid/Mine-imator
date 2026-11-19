/// @arg name
/// @arg icon
/// @arg value
/// @arg active
/// @arg script
/// @arg [axisedit]
/// @arg [text]

function togglebutton_add(name, icon, value, active, script, axisedit = X, text = "")
{
	if (text = "")
		text = text_get(name)

	array_add(togglebutton_group, [ name, icon, value, active, script, axisedit, text ], false)
}
