function action_lib_pc_type_sprite_angle_random_min(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_sprite_angle_random_min, ptype_edit.sprite_angle_random_min, ptype_edit.sprite_angle_random_min * add + value, true)
	
	ptype_edit.sprite_angle_random_min = ptype_edit.sprite_angle_random_min * add + value
}
