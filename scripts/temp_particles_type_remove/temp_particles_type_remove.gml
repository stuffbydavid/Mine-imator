/// temp_particles_type_remove(ptype)
/// @arg ptype
/// @desc Removes the given particle type from the template.

var ptype = argument0;

// Add rate
for (var t = 0; t < ds_list_size(pc_type_list); t++)
	if (pc_type_list[|t] != ptype)
		pc_type_list[|t].spawn_rate += ptype.spawn_rate / (ds_list_size(pc_type_list) - 1)

// Destroy
with (ptype)
	instance_destroy()

// Restart spawners
temp_particles_restart()
