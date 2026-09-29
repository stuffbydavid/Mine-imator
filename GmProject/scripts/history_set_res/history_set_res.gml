/// @desc Registering history for selecting/loading a new resource.
/// @arg script
/// @arg filename
/// @arg oldresource
/// @arg newresource

function history_set_res(script, fn, oldres, newres)
{
	history_pop()
	history_push()
	
	log("Action Load resource", script_get_name(script), fn)
	
	var res = newres;
	if (res = project_pack_res)
		res = app.project_pack

	var hobj = new_history(script);
	with (hobj)
	{
		filename = fn
		type = null
		
		old_res_save_id = save_id_get(oldres)
		new_res_save_id = save_id_get(newres)
		
		replaced = false
		copied = false
		
		if (res != null && instance_exists(res) && res.object_index = obj_resource) // Not camera
		{
			type = res.type
			replaced = res.replaced
			copied = res.copied
			player_skin = res.player_skin
		}
	}

	history[0] = hobj
	
	if (fn != "" && hobj.type = e_res_type.PACK && !hobj.replaced && question(text_get("questionprojectpack")))
		action_project_pack(res)

	return hobj
}
