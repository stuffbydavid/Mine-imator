/// @arg name
/// @arg value
/// @arg default
/// @arg script
/// @arg axis
/// @arg textbox
/// @arg [icon]
/// @arg [multiplier]
/// @arg [min]
/// @arg [max]
/// @arg [caption]

function textfield_group_add(name, value, def, script, axis, textbox, icon = null, mul = null, minval = null, maxval = null, caption = null)
{
	array_add(textfield_group, [ name, value, def, script, axis, textbox, icon, mul, minval, maxval, caption ], false)

	if (textbox_jump)
		ds_list_add(textbox_list, [ textbox, content_tab, dy, content_y, content_height ])
}
