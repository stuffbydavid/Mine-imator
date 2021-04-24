/// particle_event_destroy()
/// @desc Destroy event of obj_particle.

function particle_event_destroy()
{
	ds_list_delete(creator.particle_list, ds_list_find_index(creator.particle_list, id))
}
