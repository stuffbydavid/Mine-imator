/// action_lib_pc_type_color_random_start(color)
/// @arg color

function action_lib_pc_type_color_random_start(color)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_color_random_start, ptype_edit.color_random_start, color, true)
	
	ptype_edit.color_random_start = color
}
