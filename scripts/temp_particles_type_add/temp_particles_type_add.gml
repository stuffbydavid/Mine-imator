/// temp_particles_type_add()
/// @desc Adds a new particle type to the template. Returns the new one.

function temp_particles_type_add()
{
	var ptype = new_obj(obj_particle_type);
	ptype.creator = id
	
	ds_list_add(pc_type_list, ptype)
	
	ptype.name = text_get("particleeditortypedefault", string(ds_list_size(pc_type_list)))
	ptype.spawn_rate = 1 / ds_list_size(pc_type_list)
	ptype.sprite_tex = mc_res
	ptype.sprite_tex.count++
	ptype.sprite_template_tex = mc_res
	ptype.sprite_template_tex.count++
	
	// Update models
	with (ptype)
		ptype_update_sprite_vbuffers()
	
	// Update spawn %
	temp_particles_update_spawn_rate(ptype, ptype.spawn_rate)
	temp_particles_restart()
	
	return ptype
}
