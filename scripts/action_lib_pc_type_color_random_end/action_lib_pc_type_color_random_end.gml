/// action_lib_pc_type_color_random_end(color)
/// @arg color

function action_lib_pc_type_color_random_end(color)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_color_random_end, ptype_edit.color_random_end, color, true)
	
	ptype_edit.color_random_end = color
}
