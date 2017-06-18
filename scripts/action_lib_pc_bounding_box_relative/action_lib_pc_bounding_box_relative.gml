/// action_lib_pc_bounding_box_relative(relative)
/// @arg relative

var relative;

if (history_undo)
    relative = history_data.oldval
else if (history_redo)
    relative = history_data.newval
else
{
    relative = argument0
    history_set_var(action_lib_pc_bounding_box_relative, temp_edit.pc_bounding_box_relative, relative, false)
}

temp_edit.pc_bounding_box_relative = relative
