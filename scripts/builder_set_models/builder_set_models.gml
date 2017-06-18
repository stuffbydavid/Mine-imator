/// builder_set_models()

block_id_current = array3D_get(block_id, build_pos);
if (block_id_current > 0) // Skip air
{
	block_data_current = array3D_get(block_data, build_pos);
	
	// Check edges
	build_edge[e_dir.EAST]	= (build_pos[X] = build_size[X] - 1)
	build_edge[e_dir.WEST]	= (build_pos[X] = 0)
	build_edge[e_dir.SOUTH] = (build_pos[Y] = build_size[Y] - 1)
	build_edge[e_dir.NORTH] = (build_pos[Y] = 0)
	build_edge[e_dir.UP]	= (build_pos[Z] = build_size[Z] - 1)
	build_edge[e_dir.DOWN]	= (build_pos[Z] = 0)

	array3D_set(block_render_models, build_pos, block_get_render_models(block_id_current, block_data_current))
}
else			
	array3D_set(block_render_models, build_pos, null)
				
