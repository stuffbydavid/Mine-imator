/// @desc Execute scripts in clicked item lists.

function app_update_lists()
{
	if (list_item_script = null)
		return 0
	
	camera_effect_type_edit = list_item_camera_effect_edit_type

	if (is_undefined(list_item_script_value))
		script_execute(list_item_script)
	else
		script_execute(list_item_script, list_item_script_value)
	
	list_item_script = null
	list_item_script_value = null
	list_item_camera_effect_edit_type = null
	list_item_value = null

	camera_effect_type_edit = null
}
