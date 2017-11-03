/// action_lib_model(resource)
/// @arg resource

var res, hobj;
hobj = null

if (history_undo)
	res = history_undo_res()
else if (history_redo)
	res = history_redo_res()
else
{
	var fn = "";
	res = argument0
	if (res = e_option.BROWSE)
	{
		fn = file_dialog_open_model()
		
		if (!file_exists_lib(fn))
			return 0
			
		res = new_res(fn, e_res_type.MODEL)
		if (res.replaced)
			action_res_replace(fn)
		else
			with (res)
				res_load()
	}
	
	hobj = history_set_res(action_lib_model, fn, temp_edit.model, res)
	with (hobj)
	{
		old_model_save_id = save_id_get(temp_edit.model)
		new_model_save_id = save_id_get(res)
		tl_amount = 0
		part_child_amount = 0
		history_save_tl_select()
	}
		
	// Find affected timelines
	// TODO save timeline info?
	with (obj_timeline)
	{
		if (temp != temp_edit || part_list = null)
			continue
				
		with (hobj)
		{
			tl_save_id[tl_amount] = save_id_get(other.id)
				
			// Save IDs of parts
			for (var p = 0; p < ds_list_size(other.part_list); p++)
				tl_part_old_save_id[tl_amount, p] = save_id_get(other.part_list[|p])
			
			tl_amount++
		}
	}
}

tl_deselect_all()

with (temp_edit)
{
	if (model != null)
		model.count--
	model = res
	if (model != null)
		model.count++
	
	temp_update_model()
	temp_update_model_timeline_tree(hobj)
	temp_update_display_name()
	temp_update_rot_point()
}

if (history_undo)
{
	with (history_data)
	{
		// Restore old save IDs
		for (var t = 0; t < tl_amount; t++) 
			with (save_id_find(tl_save_id[t]))
				for (var p = 0; p < ds_list_size(part_list); p++)
					part_list[|p].save_id = history_data.tl_part_old_save_id[t, p]
			
		// Restore child positions in tree
		for (var m = 0; m < part_child_amount; m++) 
			with (save_id_find(part_child_save_id[m]))
				tl_set_parent(save_id_find(history_data.part_child_parent_save_id[m]), history_data.part_child_parent_tree_index[m])
		
		// Restore selection
		history_restore_tl_select()
	}
}
else if (history_redo)
{
	// Restore new save IDs
	with (history_data)
		for (var t = 0; t < tl_amount; t++) 
			with (save_id_find(tl_save_id[t]))
				for (var p = 0; p < ds_list_size(part_list); p++)
					part_list[|p].save_id = history_data.tl_part_new_save_id[t, p]
}
else
{
	// Save new IDs
	with (hobj)
		for (var t = 0; t < tl_amount; t++)
			with (save_id_find(tl_save_id[t]))
				for (var p = 0; p < ds_list_size(part_list); p++)
					hobj.tl_part_new_save_id[t, p] = save_id_get(part_list[|p])
}

app_update_tl_edit()
tl_update_list()
tl_update_matrix()

lib_preview.update = true