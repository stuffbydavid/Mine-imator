/// action_lib_pc_type_color_mix_enabled(enabled)
/// @arg enabled

var enabled;

if (history_undo)
	enabled = history_data.oldval
else if (history_redo)
	enabled = history_data.newval
else
{
	enabled = argument0
	history_set_var(action_lib_pc_type_color_mix_enabled, ptype_edit.color_mix_enabled, enabled, false)
}

ptype_edit.color_mix_enabled = enabled
