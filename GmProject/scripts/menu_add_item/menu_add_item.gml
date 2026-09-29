/// @desc Adds a new item to the dropdown menu.
/// @arg value
/// @arg text
/// @arg [texture]
/// @arg [icon]
/// @arg [script]

function menu_add_item(value, text, tex = null, icon = null, script = null)
{
	text = string_remove_newline(text)
	list_item_add(text, value, "", tex, icon, null, script)
}
