/// action_lib_pc_bounding_box_relative(relative)
/// @arg relative

function action_lib_pc_bounding_box_relative(relative)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_bounding_box_relative, obj_edit.pc_bounding_box_relative, relative, false)
	
	obj_edit.pc_bounding_box_relative = relative
}
