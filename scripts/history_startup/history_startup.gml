/// history_startup()

function history_startup()
{
	globalvar history_data;
	history[0] = null
	history_amount = 0
	history_pos = 0
	history_undo = 0
	history_redo = 0
	history_data = null
}
