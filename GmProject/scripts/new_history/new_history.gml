/// new_history(script)
/// @arg script

function new_history(script)
{
	render_samples = -1
	
	with (new_obj(obj_history))
	{
		id.script = script
		par_script = null
		save_temp_edit = save_id_get(temp_edit)
		save_ptype_edit = save_id_get(ptype_edit)
		save_tl_edit = save_id_get(tl_edit)
		save_res_edit = save_id_get(res_edit)
		save_axis_edit = axis_edit
		save_save_id_seed = save_id_seed
		
		scale_link_drag = false
		scale_link_drag_val = 0
		save_set_var = false
		usage_tl_attractor_amount = 0
		usage_tl_ik_target_amount = 0
		usage_tl_ik_target_angle_amount = 0
		usage_kf_attractor_amount = 0
		usage_kf_ik_target_amount = 0
		usage_kf_ik_target_angle_amount = 0
		
		return id
	}
}
