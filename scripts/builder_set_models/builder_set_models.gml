/// builder_set_models()

block_current = array3D_get(block_obj, build_pos);
if (block_current != null) // Skip air/unknown blocks
{
	block_state_current = array3D_get(block_state, build_pos);
	
	// Check edges
	build_edge[e_dir.EAST]	= (build_pos[X] = build_size[X] - 1)
	build_edge[e_dir.WEST]	= (build_pos[X] = 0)
	build_edge[e_dir.SOUTH] = (build_pos[Y] = build_size[Y] - 1)
	build_edge[e_dir.NORTH] = (build_pos[Y] = 0)
	build_edge[e_dir.UP]	= (build_pos[Z] = build_size[Z] - 1)
	build_edge[e_dir.DOWN]	= (build_pos[Z] = 0)

	array3D_set(block_render_models, build_pos, block_get_render_models(block_current, block_state_current))
}
else			
	array3D_set(block_render_models, build_pos, null)
				
