function action_value_paste()
{
	camera_effect_type_edit = context_menu_camera_effect_type_edit
	biome_color_edit = context_menu_biome_color_edit
	script_execute(context_menu_value_script, context_menu_copy, false)
	biome_color_edit = null
	camera_effect_type_edit = null
}
