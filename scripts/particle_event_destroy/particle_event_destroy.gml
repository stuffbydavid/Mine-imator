/// particle_event_destroy()
/// @desc Destroy event of obj_particle.

ds_list_delete(creator.particle_list, ds_list_find_index(creator.particle_list, id))
