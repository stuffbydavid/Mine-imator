/// action_lib_pc_destroy_at_amount(destroy)
/// @arg destroy

var destroy;

if (history_undo)
	destroy = history_data.old_value
else if (history_redo)
	destroy = history_data.new_value
else
{
	destroy = argument0
	history_set_var(action_lib_pc_destroy_at_amount, temp_edit.pc_destroy_at_amount, destroy, false)
}

temp_edit.pc_destroy_at_amount = destroy
