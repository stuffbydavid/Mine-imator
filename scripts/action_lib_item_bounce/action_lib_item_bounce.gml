/// action_lib_item_bounce(bounce)
/// @arg bounce

function action_lib_item_bounce(bounce) {

	if (!history_undo && !history_redo)
		history_set_var(action_lib_item_bounce, temp_edit.item_bounce, bounce, false)
	
	temp_edit.item_bounce = bounce
}
