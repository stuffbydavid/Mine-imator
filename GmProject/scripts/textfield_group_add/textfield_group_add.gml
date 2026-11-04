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
	textfield_name = array_add(textfield_name, name)
	textfield_value = array_add(textfield_value, value)
	textfield_default = array_add(textfield_default, def)
	textfield_script = array_add(textfield_script, script)
	textfield_axis = array_add(textfield_axis, axis)
	textfield_textbox = array_add(textfield_textbox, textbox)
	
	if (textbox_jump)
		ds_list_add(textbox_list, [ textbox, content_tab, dy, content_y, content_height ])
	
	textfield_icon = array_add(textfield_icon, icon)
	textfield_mul = array_add(textfield_mul, mul)
	
	if (minval != null)
	{
		textfield_min = array_add(textfield_min, minval)
		textfield_max = array_add(textfield_max, maxval)
	}
	
	textfield_caption = array_add(textfield_caption, caption)
	
	textfield_amount = array_length(textfield_name)
}
