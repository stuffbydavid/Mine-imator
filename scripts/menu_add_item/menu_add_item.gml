/// menu_add_item(value, text, [texture, [icon, [script]]])
/// @arg value
/// @arg text
/// @arg [texture
/// @arg [icon
/// @arg [script]]]
/// @desc Adds a new item to the dropdown menu.

function menu_add_item()
{
	var value, text, tex, icon, script;
	value = argument[0]
	text = string_remove_newline(argument[1])
	
	if (argument_count > 2)
		tex = argument[2]
	else
		tex = null
	
	if (argument_count > 3)
		icon = argument[3]
	else
		icon = null
	
	if (argument_count > 4)
		script = argument[4]
	else
		script = null
	
	list_item_add(text, value, "", tex, icon, null, script)
}
