function action_value_reset()
{
	camera_effect_type_edit = context_menu_camera_effect_type_edit
	history_separate = true
	script_execute(context_menu_value_script, context_menu_value_default, false)
	history_separate = false
	camera_effect_type_edit = null
}
