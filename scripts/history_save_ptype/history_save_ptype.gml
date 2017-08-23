/// history_save_ptype(ptype)
/// @arg ptype
/// @desc Saves a particle type into memory.

var ptype, save;
ptype = argument0
save = new(obj_history_save)
save.hobj = id

with (ptype)
	ptype_copy(save)

with (save)
{
	save_id = ptype.save_id
	ptype_get_save_ids()
}

return save
