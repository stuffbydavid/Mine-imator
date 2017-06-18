/// temp_particles_type_clear()
/// @desc Clears all particle types from the template.

while (pc_types > 0)
    with (pc_type[0])
        instance_destroy()
