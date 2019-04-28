/// history_restore_ptype(save, creator)
/// @arg save
/// @arg creator
/// @desc Adds a saved particle type to the given creator.

var save, ptype;
save = argument0
ptype = new(obj_particle_type)

with (save)
	ptype_copy(ptype)
	
with (ptype)
{
	save_id = save.save_id
	ptype_find_save_ids()
	
	creator = argument1
	ds_list_insert(creator.pc_type_list, creator_index, id)
	
	sprite_tex.count++
	sprite_template_tex.count++
	ptype_update_sprite_vbuffers()
}

return ptype
