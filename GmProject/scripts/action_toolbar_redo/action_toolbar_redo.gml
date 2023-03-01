/// action_toolbar_redo()

function action_toolbar_redo()
{
	if (history_pos = 0)
		return 0
	
	action_tl_play_break()
	
	history_pos--
	
	history_data = history[history_pos]
	temp_edit = save_id_find(history_data.save_temp_edit)
	ptype_edit = save_id_find(history_data.save_ptype_edit)
	tl_edit = save_id_find(history_data.save_tl_edit)
	res_edit = save_id_find(history_data.save_res_edit)
	axis_edit = history_data.save_axis_edit
	save_id_seed = history_data.save_save_id_seed
	
	log("Redo", script_get_name(history_data.script))
	
	history_redo = true
	
	if (history_data.save_set_var)
		script_execute(history_data.script, history_data.new_value, false)
	else
		script_execute(history_data.script)
	
	history_redo = false
	
	history_resource_update = true
	render_samples = -1
}
