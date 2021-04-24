/// action_lib_pc_type_sprite_angle_add_israndom(israndom)
/// @arg israndom

function action_lib_pc_type_sprite_angle_add_israndom(israndom)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_sprite_angle_add_israndom, ptype_edit.sprite_angle_add_israndom, israndom, false)
	
	ptype_edit.sprite_angle_add_israndom = israndom
}
