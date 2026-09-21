/// action_toolbar_undo()

function action_toolbar_undo()
{
	// The active build preview occupies one history slot
	if (history_pos = history_amount ||
		(place_build && (history_pos + 1 >= history_amount || !history[history_pos + 1].build_action)))
		return 0

	if (place_build)
		history_build_action(false)
	
	action_tl_play_break()
	
	history_data = history[history_pos]
	temp_edit = save_id_find(history_data.save_temp_edit)
	obj_edit = save_id_find(history_data.save_obj_edit)
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

	if (obj_edit = null)
		obj_edit = save_id_find(history_data.save_obj_edit)
	
	history_undo = false
	
	history_pos++
	if (place_build)
		history_build_action(true)
	
	history_resource_update = true
	render_samples = -1
	project_update_counts()
}
