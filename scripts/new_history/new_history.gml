/// new_history(script)
/// @arg script

render_samples = -1

with (new(obj_history))
{
	script = argument0
	par_script = null
	save_temp_edit = save_id_get(temp_edit)
	save_ptype_edit = save_id_get(ptype_edit)
	save_tl_edit = save_id_get(tl_edit)
	save_res_edit = save_id_get(res_edit)
	save_axis_edit = axis_edit
	save_save_id_seed = save_id_seed
	
	return id
}

