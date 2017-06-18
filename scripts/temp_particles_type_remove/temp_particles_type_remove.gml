/// temp_particles_type_remove(ptype)
/// @arg ptype
/// @desc Removes the given particle type from the template.

var ptype = argument0;

// Add rate
for (var t = 0; t < pc_types; t++)
	if (pc_type[t] != ptype)
		pc_type[t].spawn_rate += ptype.spawn_rate / (pc_types - 1)

// Destroy
with (ptype)
	instance_destroy()

// Restart spawners
temp_particles_restart()
