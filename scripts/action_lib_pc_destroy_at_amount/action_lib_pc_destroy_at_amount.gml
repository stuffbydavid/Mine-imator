/// action_lib_pc_destroy_at_amount(destroy)
/// @arg destroy

var destroy;

if (history_undo)
	destroy = history_data.oldval
else if (history_redo)
	destroy = history_data.newval
else
{
	destroy = argument0
	history_set_var(action_lib_pc_destroy_at_amount, temp_edit.pc_destroy_at_amount, destroy, false)
}

temp_edit.pc_destroy_at_amount = destroy
