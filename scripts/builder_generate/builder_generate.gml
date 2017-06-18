/// builder_generate()
/// @desc Generate triangles from the block render models.

block_id_current = array3D_get(block_id, build_pos)
block_data_current = array3D_get(block_data, build_pos)
block_pos = point3D_mul(build_pos, block_size)
block_color = null
			
// Check edges
build_edge[e_dir.EAST]	= (build_pos[X] = build_size[X] - 1)
build_edge[e_dir.WEST]	= (build_pos[X] = 0)
build_edge[e_dir.SOUTH] = (build_pos[Y] = build_size[Y] - 1)
build_edge[e_dir.NORTH] = (build_pos[Y] = 0)
build_edge[e_dir.UP]	= (build_pos[Z] = build_size[Z] - 1)
build_edge[e_dir.DOWN]	= (build_pos[Z] = 0)

// Check adjacent
for (var f = 0; f < e_dir.amount; f++)
{
	if (build_edge[f])
		block_render_models_dir[f] = null
	else
		block_render_models_dir[f] = array3D_get(block_render_models, point3D_add(build_pos, dir_get_vec3(f)))
}
			
// Get render models
var models = array3D_get(block_render_models, build_pos);
if (models = 0) // Requires other models
	models = block_get_render_models(block_id_current, block_data_current, true)

if (models != null)
{
	if (is_array(models)) // Generate from render models
		block_render_models_generate(models)
	else // Use script for triangles
		script_execute(models)
}