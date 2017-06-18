/// action_lib_pc_bounding_box_type(type)
/// @arg type

var type;

if (history_undo)
	type = history_data.oldval
else if (history_redo)
	type = history_data.newval
else
{
	type = argument0
	history_set_var(action_lib_pc_bounding_box_type, temp_edit.pc_bounding_box_type, type, false)
}

temp_edit.pc_bounding_box_type = type
