function action_lib_pc_type_sprite_angle_random_max(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_sprite_angle_random_max, ptype_edit.sprite_angle_random_max, ptype_edit.sprite_angle_random_max * add + value, true)
	
	ptype_edit.sprite_angle_random_max = ptype_edit.sprite_angle_random_max * add + value
}
