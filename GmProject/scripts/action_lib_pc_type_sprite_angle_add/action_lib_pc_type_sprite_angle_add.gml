/// action_lib_pc_type_sprite_angle_add(value, add)
/// @arg value
/// @arg add

function action_lib_pc_type_sprite_angle_add(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_scale_add, ptype_edit.sprite_angle_add, ptype_edit.sprite_angle_add * add + val, true)
	
	ptype_edit.sprite_angle_add = ptype_edit.sprite_angle_add * add + val
}
