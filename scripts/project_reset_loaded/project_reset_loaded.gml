/// project_reset_loaded()

ds_map_clear(save_id_map)
tree_array = 0
background_loaded = false

with (obj_template)
	loaded = false

with (obj_particle_type)
	loaded = false

with (obj_timeline)
{
	tree_array = 0
	loaded = false
}

with (obj_resource)
	loaded = false

with (obj_keyframe)
	loaded = false