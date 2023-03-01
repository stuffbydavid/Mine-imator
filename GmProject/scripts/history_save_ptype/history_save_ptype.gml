/// history_save_ptype(ptype)
/// @arg ptype
/// @desc Saves a particle type into memory.

function history_save_ptype(ptype)
{
	var save;
	save = new_obj(obj_history_save)
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
