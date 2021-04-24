/// toast_add_action(text, script, value)
/// @arg text
/// @arg script
/// @arg value

function toast_add_action(text, script, value)
{
	ds_list_add(toast_last.actions, text)
	ds_list_add(toast_last.actions, script)
	ds_list_add(toast_last.actions, value)
}
