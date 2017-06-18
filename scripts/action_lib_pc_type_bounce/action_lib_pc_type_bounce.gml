/// action_lib_pc_type_bounce(bounce)
/// @arg bounce

var bounce;

if (history_undo)
	bounce = history_data.oldval
else if (history_redo)
	bounce = history_data.newval
else
{
	bounce = argument0
	history_set_var(action_lib_pc_type_bounce, ptype_edit.bounce, bounce, false)
}

ptype_edit.bounce = bounce
