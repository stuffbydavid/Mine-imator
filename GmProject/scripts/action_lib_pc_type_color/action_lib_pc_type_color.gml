/// action_lib_pc_type_color(value)
/// @arg value

function action_lib_pc_type_color(color)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_color, ptype_edit.color, color, true)
	
	ptype_edit.color = color
}
