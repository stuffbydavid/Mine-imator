/// history_set_res(script, filename, oldresource, newresource)
/// @arg script
/// @arg filename
/// @arg oldresource
/// @arg newresource
/// @desc Registering history for selecting/loading a new resource.

function history_set_res(script, fn, oldres, newres)
{
	history_pop()
	history_push()
	
	log("Action Load resource", script_get_name(script), fn)
	
	with (new_history(script))
	{
		filename = fn
		type = null
		old_res_save_id = save_id_get(oldres)
		new_res_save_id = save_id_get(newres)
		replaced = false
		copied = false
		
		if (newres != null && newres.object_index = obj_resource) // Not camera
		{
			type = newres.type
			replaced = newres.replaced
			copied = newres.copied
			player_skin = newres.player_skin 
		}
		
		other.history[0] = id
		return id
	}
}
