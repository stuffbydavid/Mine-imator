/// action_lib_pc_type_bounding_box(box)
/// @arg box

function action_lib_pc_type_bounding_box(box)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_bounding_box, ptype_edit.bounding_box, box, false)
	
	ptype_edit.bounding_box = box
}
