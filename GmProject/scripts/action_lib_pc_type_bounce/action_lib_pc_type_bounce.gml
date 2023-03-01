/// action_lib_pc_type_bounce(bounce)
/// @arg bounce

function action_lib_pc_type_bounce(bounce)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_bounce, ptype_edit.bounce, bounce, false)
	
	ptype_edit.bounce = bounce
}
