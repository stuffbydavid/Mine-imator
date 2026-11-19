function action_project_tempo(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_tempo, project_tempo, project_tempo * add + value, true)
	
	project_tempo = project_tempo * add + value
	tl_update_length()
}
