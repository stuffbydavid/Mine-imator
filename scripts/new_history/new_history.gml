/// new_history(script)
/// @arg script

with (new(obj_history))
{
	script = argument0
	parscript = null
	save_temp_edit = iid_get(temp_edit)
	save_ptype_edit = iid_get(ptype_edit)
	save_tl_edit = iid_get(tl_edit)
	save_res_edit = iid_get(res_edit)
	save_axis_edit = axis_edit
	save_iid_current = iid_current
	
	return id
}

