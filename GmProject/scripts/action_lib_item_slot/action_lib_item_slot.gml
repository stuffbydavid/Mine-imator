function action_lib_item_slot(index)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_item_slot, obj_edit.item_slot, index, false)
	
	with (obj_edit)
	{
		item_slot = index
		render_generate_item()
	}
	
	lib_preview.update = true
}
