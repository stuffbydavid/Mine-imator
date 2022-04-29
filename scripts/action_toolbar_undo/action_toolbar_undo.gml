/// action_toolbar_undo()

function action_toolbar_undo()
{
	if (history_pos = history_amount)
		return 0
	
	action_tl_play_break()
	
	history_data = history[history_pos]
	temp_edit = save_id_find(history_data.save_temp_edit)
	ptype_edit = save_id_find(history_data.save_ptype_edit)
	tl_edit = save_id_find(history_data.save_tl_edit)
	res_edit = save_id_find(history_data.save_res_edit)
	axis_edit = history_data.save_axis_edit
	save_id_seed = history_data.save_save_id_seed
	
	log("Undo", script_get_name(history_data.script))
	
	history_undo = true
	
	if (history_data.save_set_var)
		script_execute(history_data.script, history_data.old_value, false)
	else
		script_execute(history_data.script)
	
	history_undo = false
	
	history_pos++
	
	history_resource_update = true
	render_samples = -1
}
