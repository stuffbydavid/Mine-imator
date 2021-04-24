/// action_lib_pc_type_sprite_angle(value, add)
/// @arg value
/// @arg add

function action_lib_pc_type_sprite_angle(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_scale, ptype_edit.sprite_angle, ptype_edit.sprite_angle * add + val, true)
	
	ptype_edit.sprite_angle = ptype_edit.sprite_angle * add + val
}
