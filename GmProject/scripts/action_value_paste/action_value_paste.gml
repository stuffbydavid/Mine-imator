function action_value_paste()
{
	camera_effect_type_edit = context_menu_camera_effect_type_edit
	script_execute(context_menu_value_script, context_menu_copy, false)
	camera_effect_type_edit = null
}
