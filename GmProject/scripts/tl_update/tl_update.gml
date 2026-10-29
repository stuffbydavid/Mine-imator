function tl_update()
{
	tl_update_value_types()
	tl_update_rot_point()
	tl_update_type_name()
	tl_update_display_name()
	tl_update_depth()
	tl_update_model_shape()

	if (type = e_tl_type.SCENERY && (array_length(blocks_added) > 0 || array_length(block_meshes_edit) > 0))
		tl_update_block_meshes()
	
	render_world_changed()
	
	if (type = e_tl_type.PARTICLE_SPAWNER)
		particle_spawner_init()
}
