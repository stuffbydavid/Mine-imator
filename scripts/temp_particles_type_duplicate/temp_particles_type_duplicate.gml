/// temp_particles_type_duplicate(type)
/// @arg type
/// @desc Duplicates the particle type, returns the new one.

function temp_particles_type_duplicate(type)
{
	var ptype = new_obj(obj_particle_type);
	
	// Copy data
	with (type)
		ptype_copy(ptype)
	
	// Insert
	ds_list_add(pc_type_list, ptype)
	
	ptype.spawn_rate = 1 / ds_list_size(pc_type_list)
	ptype.sprite_tex.count++
	
	// Update models
	with (ptype)
		ptype_update_sprite_vbuffers()
	
	// Update spawn %
	temp_particles_update_spawn_rate(ptype, ptype.spawn_rate)
	temp_particles_restart()
	
	return ptype
}
