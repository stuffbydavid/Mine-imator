function action_value_reset()
{
	camera_effect_type_edit = context_menu_camera_effect_type_edit
	biome_color_edit = context_menu_biome_color_edit
	history_separate = true
	script_execute(context_menu_value_script, context_menu_value_default, false)
	history_separate = false
	biome_color_edit = null
	camera_effect_type_edit = null
}
