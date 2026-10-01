function action_value_set_color()
{
	camera_effect_type_edit = context_menu_camera_effect_type_edit
	script_execute(context_menu_value_script, list_item_script_value, false)
	camera_effect_type_edit = null
}
