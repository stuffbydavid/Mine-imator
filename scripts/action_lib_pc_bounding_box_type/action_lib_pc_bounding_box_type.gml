/// action_lib_pc_bounding_box_type(type)
/// @arg type

function action_lib_pc_bounding_box_type(type)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_bounding_box_type, temp_edit.pc_bounding_box_type, type, false)
	
	temp_edit.pc_bounding_box_type = type
}
