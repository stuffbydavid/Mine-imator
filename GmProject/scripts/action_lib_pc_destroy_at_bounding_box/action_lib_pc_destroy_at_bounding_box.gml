/// action_lib_pc_destroy_at_bounding_box(destroy)
/// @arg destroy

function action_lib_pc_destroy_at_bounding_box(destroy)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_destroy_at_bounding_box, temp_edit.pc_destroy_at_bounding_box, destroy, false)
	
	temp_edit.pc_destroy_at_bounding_box = destroy
}
