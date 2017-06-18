/// temp_particles_type_duplicate(type)
/// @arg type
/// @desc Duplicates the particle type, returns the new one.

var ptype = new(obj_particle_type);

// Copy data
with (argument0)
    ptype_copy(ptype)
    
// Insert
ptype.creator_pos = pc_types
pc_type[pc_types] = ptype
pc_types++

ptype.spawn_rate = 1/pc_types
ptype.sprite_tex.count++

// Update models
with (ptype)
    ptype_update_sprite_vbuffers()

// Update spawn %
temp_particles_update_spawn_rate(ptype, ptype.spawn_rate)
temp_particles_restart()

return ptype
