/// history_restore_ptype(save, creator)
/// @arg save
/// @arg creator
/// @desc Adds a saved particle type to the given creator.

function history_restore_ptype(save, creator)
{
	var ptype;
	ptype = new_obj(obj_particle_type)

	// Creating new particle type will offset save ids
	save_id_seed--

	with (save)
		ptype_copy(ptype)
	
	with (ptype)
	{
		save_id = save.save_id
		ptype_find_save_ids()
	
		id.creator = creator
		ds_list_insert(id.creator.pc_type_list, creator_index, id)
	
		sprite_tex.count++
		sprite_template_tex.count++
		ptype_update_sprite_vbuffers()
	}

	return ptype
}
