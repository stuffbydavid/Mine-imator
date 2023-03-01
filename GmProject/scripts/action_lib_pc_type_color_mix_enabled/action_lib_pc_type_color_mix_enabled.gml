/// action_lib_pc_type_color_mix_enabled(enabled)
/// @arg enabled

function action_lib_pc_type_color_mix_enabled(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_color_mix_enabled, ptype_edit.color_mix_enabled, enabled, false)
	
	ptype_edit.color_mix_enabled = enabled
}
