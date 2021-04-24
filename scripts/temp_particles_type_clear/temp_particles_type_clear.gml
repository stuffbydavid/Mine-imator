/// temp_particles_type_clear()
/// @desc Clears all particle types from the template.

function temp_particles_type_clear()
{
	while (ds_list_size(pc_type_list))
		with (pc_type_list[|0])
			instance_destroy()
}
