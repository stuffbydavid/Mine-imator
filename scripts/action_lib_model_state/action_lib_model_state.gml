/// action_lib_model_state(value)
/// @arg value

var val, state, hobj;
hobj = null

if (history_undo)
{
	val = history_data.old_value
	state = history_data.state
}
else {

	if (history_redo)
	{
		val = history_data.new_value
		state = history_data.state
	}
	else
	{
		val = argument0
		state = menu_model_state.name
		hobj = history_set_var(action_lib_model_state, temp_edit.model_state_map[?state], val, false)
		with (hobj)
		{
			id.state = state
			tl_amount = 0
			part_child_amount = 0
			history_save_tl_select()
		}
		
		// Find affected timelines
		with (obj_timeline)
		{
			if (temp != temp_edit || part_of != null)
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
}

tl_deselect_all()

with (temp_edit)
{
	model_state_map[?state] = val
	model_state = state_vars_map_to_string(model_state_map)
	temp_update_model()
	temp_update_model_timeline_tree(hobj)
	temp_update_display_name()
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