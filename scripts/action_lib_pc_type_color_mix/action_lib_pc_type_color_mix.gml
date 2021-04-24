/// action_lib_pc_type_color_mix(color)
/// @arg color

function action_lib_pc_type_color_mix(color)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_color_mix, ptype_edit.color_mix, color, true)
	
	ptype_edit.color_mix = color
}
