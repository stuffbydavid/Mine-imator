function action_res_item_sheet_size(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_res_item_sheet_size, res_edit.item_sheet_size[axis_edit], res_edit.item_sheet_size[axis_edit] * add + value, true)
	
	with (res_edit)
		item_sheet_size[axis_edit] = item_sheet_size[axis_edit] * add + value
	
	with (obj_template)
		if (item_tex = res_edit)
			render_generate_item()
	
	lib_preview.update = true
}
