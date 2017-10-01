/// builder_generate()
/// @desc Generate triangles from the block render models.

block_current = array3D_get(block_obj, build_size, build_pos)
if (is_undefined(block_current))
	return 0
	
block_state_current = array3D_get(block_state, build_size, build_pos)
block_pos = point3D_mul(build_pos, block_size)
block_color = null

// Random X & Y offset
if (block_current.random_offset && build_size[X] * build_size[Y] * build_size[Z] > 1)
{
	random_set_seed(build_pos[X] * build_size[Y] * build_size[Z] + build_pos[Y] * build_size[Z] + build_pos[Z])
	block_pos[X] += irandom_range(-4, 4)
	block_pos[Y] += irandom_range(-4, 4)
}
	
// Set wind
vertex_wave = block_current.wind_axis
if (block_current.wind_zmin != null)
	vertex_wave_zmin = block_pos[Z] + block_current.wind_zmin
			
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
	{
		if (app.setting_schematic_remove_edges && (build_size[X] > 200 && build_size[Y] > 200))
			block_render_models_dir[f] = array(solid_model)
		else
			block_render_models_dir[f] = null
	}
	else
		block_render_models_dir[f] = array3D_get(block_render_models, build_size, point3D_add(build_pos, dir_get_vec3(f)))
}
			
// Get render models
var models = array3D_get(block_render_models, build_size, build_pos);
if (models = 0) // Requires other models
	models = block_get_render_models(block_current, block_state_current, true)
	
if (models != null)
{
	
	if (is_array(models)) // Generate from render models
	{
		if (models[0] = 0) {log(block_current.name, models)}
		block_render_models_generate(models)
	}else // Use script for triangles
		script_execute(models)
}

// Reset wind and brightness
vertex_wave = e_vertex_wave.NONE
vertex_wave_zmin = null
vertex_brightness = 0