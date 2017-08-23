/// action_lib_shape_tex_mapped(map)
/// @arg map

var map;

if (history_undo)
	map = history_data.old_value
else if (history_redo)
	map = history_data.new_value
else
{
	map = argument0
	history_set_var(action_lib_shape_tex_mapped, temp_edit.shape_tex_mapped, map, false)
}

with (temp_edit)
{
	shape_tex_mapped = map
	temp_update_shape()
}
lib_preview.update = true
