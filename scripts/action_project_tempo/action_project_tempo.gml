/// action_project_tempo(value, add)
/// @arg value
/// @arg add

function action_project_tempo(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_tempo, project_tempo, project_tempo * add + val, 1)
	
	project_tempo = project_tempo * add + val
	tl_update_length()
}
