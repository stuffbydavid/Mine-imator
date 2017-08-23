/// action_lib_pc_type_color(value)
/// @arg value

var col;

if (history_undo)
	col = history_data.old_value
else if (history_redo)
	col = history_data.new_value
else
{
	col = argument0
	history_set_var(action_lib_pc_type_color, ptype_edit.color, col, true)
}

ptype_edit.color = col
