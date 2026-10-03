function history_startup()
{
	globalvar history_data, history_undo, history_redo, history_separate;
	history_data = null
	history_undo = false
	history_redo = false
	history_separate = false
	
	history[0] = null
	history_amount = 0
	history_pos = 0
	history_resource_update = false
}
