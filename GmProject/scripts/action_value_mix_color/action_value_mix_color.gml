function action_value_mix_color()
{
	camera_effect_type_edit = context_menu_camera_effect_type_edit
	script_execute(context_menu_value_script, minecraft_mix_colors([ context_menu_value, list_item_script_value ]), false)
	camera_effect_type_edit = null
}
