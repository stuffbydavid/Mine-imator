/// temp_particles_type_add()
/// @desc Adds a new particle type to the template. Returns the new one.

var ptype = new(obj_particle_type);
ptype.creator = id

ds_list_add(pc_type_list, ptype)

ptype.name = text_get("particleeditortypedefault", string(ds_list_size(pc_type_list)))
ptype.spawn_rate = 1 / ds_list_size(pc_type_list)
ptype.sprite_tex = res_def
ptype.sprite_tex.count++

// Update models
with (ptype)
	ptype_update_sprite_vbuffers()
	
// Update spawn %
temp_particles_update_spawn_rate(ptype, ptype.spawn_rate)
temp_particles_restart()

return ptype
