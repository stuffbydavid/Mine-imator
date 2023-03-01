/// action_lib_item_slot(slot)
/// @arg slot

function action_lib_item_slot(slot)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_item_slot, temp_edit.item_slot, slot, false)
	
	with (temp_edit)
	{
		item_slot = slot
		render_generate_item()
	}
	
	lib_preview.update = true
}
