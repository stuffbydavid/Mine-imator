/// action_lib_item_3d(is3d)
/// @arg is3d

var is3d;

if (history_undo)
	is3d = history_data.oldval
else if (history_redo)
	is3d = history_data.newval
else
{
	is3d = argument0
	history_set_var(action_lib_item_3d, temp_edit.item_3d, is3d, false)
}

with (temp_edit)
{
	item_3d = is3d
	temp_update_item()
	temp_update_rot_point()
}

lib_preview.update = true
