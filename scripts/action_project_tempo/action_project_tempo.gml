/// action_project_tempo(value, add)
/// @arg value
/// @arg add

var val, add;
add = false

if (history_undo)
	val = history_data.old_value
else if (history_redo)
	val = history_data.new_value
else
{
	val = argument0
	add = argument1
	history_set_var(action_project_tempo, project_tempo, project_tempo * add + val, 1)
}

project_tempo = project_tempo * add + val
tl_update_length()
