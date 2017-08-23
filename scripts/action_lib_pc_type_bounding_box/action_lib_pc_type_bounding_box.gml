/// action_lib_pc_type_bounding_box(box)
/// @arg box

var box;

if (history_undo)
	box = history_data.old_value
else if (history_redo)
	box = history_data.new_value
else
{
	box = argument0
	history_set_var(action_lib_pc_type_bounding_box, ptype_edit.bounding_box, box, false)
}

ptype_edit.bounding_box = box
