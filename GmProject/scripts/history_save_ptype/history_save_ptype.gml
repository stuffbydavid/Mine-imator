/// @desc Saves a particle type into memory.
/// @arg particletype

function history_save_ptype(ptype)
{
	var save = new_obj(obj_history_save);
	save.hobj = id
	
	with (ptype)
		ptype_copy(save)
	
	with (save)
	{
		save_id = ptype.save_id
		ptype_get_save_ids()
	}
	
	return save
}
