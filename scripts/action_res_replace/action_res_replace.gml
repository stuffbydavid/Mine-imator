/// action_res_replace()

var hobj = null;

if (!history_undo && !history_redo)
{
	with (res_edit)
		if (!res_load_browse())
			return 0
		
	hobj = history_set(action_res_replace)
	with (hobj)
	{
		part_amount = 0
		part_child_amount = 0
		history_save_tl_select()
	}
	
	tl_deselect_all()
}

with (obj_template)
{
	if (scenery = res_edit)
		temp_set_scenery(scenery, !app.history_undo, hobj)
	else if (item_tex = res_edit)
		temp_update_item()
}

// Restore old timelines
if (history_undo)
	with (history_data)
		history_restore_scenery()

tl_update_length()
tl_update_list()
tl_update_matrix()

app_update_tl_edit()

lib_preview.update = true
res_preview.update = true
res_preview.reset_view = true
