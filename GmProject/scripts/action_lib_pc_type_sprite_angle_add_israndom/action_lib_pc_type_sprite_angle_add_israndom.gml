function action_lib_pc_type_sprite_angle_add_israndom(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_sprite_angle_add_israndom, ptype_edit.sprite_angle_add_israndom, enabled, false)
	
	ptype_edit.sprite_angle_add_israndom = enabled
}
