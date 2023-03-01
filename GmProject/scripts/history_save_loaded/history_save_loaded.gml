/// history_save_loaded()
/// @desc Stores the newly loaded objects.

function history_save_loaded()
{
	loaded_amount = 0
	
	with (obj_template)
		if (loaded)
			other.loaded_save_id[other.loaded_amount++] = save_id
	
	with (obj_timeline)
		if (loaded)
			other.loaded_save_id[other.loaded_amount++] = save_id
	
	with (obj_resource)
		if (loaded)
			other.loaded_save_id[other.loaded_amount++] = save_id
}
