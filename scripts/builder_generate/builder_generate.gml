/// builder_generate()
/// @desc Generate triangles from the block render models.

block_current = array3D_get(block_obj, build_size_z, build_pos_x, build_pos_y, build_pos_z)
if (block_current = null)
	return 0

block_state_id_current = array3D_get(block_state_id, build_size_z, build_pos_x, build_pos_y, build_pos_z)
block_pos_x = build_pos_x * block_size
block_pos_y = build_pos_y * block_size
block_pos_z = build_pos_z * block_size
block_color = null

// Set wind
vertex_wave = block_current.wind_axis
if (block_current.wind_zmin != null)
	vertex_wave_zmin = block_pos_z + block_current.wind_zmin
	
// Check edges for culling

// X+
build_edge_xp = (build_pos_x = build_size_x - 1)
block_face_min_depth_xp = null
if (build_edge_xp)
{
	if (!build_edges)
	{
		block_face_full_xp = true
		block_face_min_depth_xp = e_block_depth.DEPTH0
	}
}
else
{
	var othermodel = array3D_get(block_render_model, build_size_z, build_pos_x + 1, build_pos_y, build_pos_z);
	if (othermodel != null)
	{
		block_face_full_xp = othermodel.face_full_xn
		block_face_min_y_xp = othermodel.face_min_y_xn
		block_face_max_y_xp = othermodel.face_max_y_xn
		block_face_min_z_xp = othermodel.face_min_z_xn
		block_face_max_z_xp = othermodel.face_max_z_xn
		block_face_min_depth_xp = othermodel.face_min_depth_xn
	}
}

// X-
build_edge_xn = (build_pos_x = 0)
block_face_min_depth_xn = null
if (build_edge_xn)
{
	if (!build_edges)
	{
		block_face_full_xn = true
		block_face_min_depth_xn = e_block_depth.DEPTH0
	}
}
else
{
	var othermodel = array3D_get(block_render_model, build_size_z, build_pos_x - 1, build_pos_y, build_pos_z);
	if (othermodel != null)
	{
		block_face_full_xn = othermodel.face_full_xp
		block_face_min_y_xn = othermodel.face_min_y_xp
		block_face_max_y_xn = othermodel.face_max_y_xp
		block_face_min_z_xn = othermodel.face_min_z_xp
		block_face_max_z_xn = othermodel.face_max_z_xp
		block_face_min_depth_xn = othermodel.face_min_depth_xp
	}
}

// Y+
build_edge_yp = (build_pos_y = build_size_y - 1)
block_face_min_depth_yp = null
if (build_edge_yp)
{
	if (!build_edges)
	{
		block_face_full_yp = true
		block_face_min_depth_yp = e_block_depth.DEPTH0
	}
}
else
{
	var othermodel = array3D_get(block_render_model, build_size_z, build_pos_x, build_pos_y + 1, build_pos_z);
	if (othermodel != null)
	{
		block_face_full_yp = othermodel.face_full_yn
		block_face_min_x_yp = othermodel.face_min_x_yn
		block_face_max_x_yp = othermodel.face_max_x_yn
		block_face_min_z_yp = othermodel.face_min_z_yn
		block_face_max_z_yp = othermodel.face_max_z_yn
		block_face_min_depth_yp = othermodel.face_min_depth_yn
	}
}

// Y-
build_edge_yn = (build_pos_y = 0)
block_face_min_depth_yn = null
if (build_edge_yn)
{
	if (!build_edges)
	{
		block_face_full_yn = true
		block_face_min_depth_yn = e_block_depth.DEPTH0
	}
}
else
{
	var othermodel = array3D_get(block_render_model, build_size_z, build_pos_x, build_pos_y - 1, build_pos_z);
	if (othermodel != null)
	{
		block_face_full_yn = othermodel.face_full_yp
		block_face_min_x_yn = othermodel.face_min_x_yp
		block_face_max_x_yn = othermodel.face_max_x_yp
		block_face_min_z_yn = othermodel.face_min_z_yp
		block_face_max_z_yn = othermodel.face_max_z_yp
		block_face_min_depth_yn = othermodel.face_min_depth_yp
	}
}

// Z+
build_edge_zp = (build_pos_z = build_size_z - 1)
block_face_min_depth_zp = null
if (build_edge_zp)
{
	if (!build_edges)
	{
		block_face_full_zp = true
		block_face_min_depth_zp = e_block_depth.DEPTH0
	}
}
else
{
	var othermodel = array3D_get(block_render_model, build_size_z, build_pos_x, build_pos_y, build_pos_z + 1);
	if (othermodel != null)
	{
		block_face_full_zp = othermodel.face_full_zn
		block_face_min_x_zp = othermodel.face_min_x_zn
		block_face_max_x_zp = othermodel.face_max_x_zn
		block_face_min_y_zp = othermodel.face_min_y_zn
		block_face_max_y_zp = othermodel.face_max_y_zn
		block_face_min_depth_zp = othermodel.face_min_depth_zn
	}
}

// Z-
build_edge_zn = (build_pos_z = 0)
block_face_min_depth_zn = null
if (build_edge_zn)
{
	if (!build_edges)
	{
		block_face_full_zn = true
		block_face_min_depth_zn = e_block_depth.DEPTH0
	}
}
else
{
	var othermodel = array3D_get(block_render_model, build_size_z, build_pos_x, build_pos_y, build_pos_z - 1);
	if (othermodel != null)
	{
		block_face_full_zn = othermodel.face_full_zp
		block_face_min_x_zn = othermodel.face_min_x_zp
		block_face_max_x_zn = othermodel.face_max_x_zp
		block_face_min_y_zn = othermodel.face_min_y_zp
		block_face_max_y_zn = othermodel.face_max_y_zp
		block_face_min_depth_zn = othermodel.face_min_depth_zp
	}
}

// Get render model
var model = array3D_get(block_render_model, build_size_z, build_pos_x, build_pos_y, build_pos_z);
if (model != null)
{
	// Multipart
	if (is_array(model))
	{
		var modellen = array_length_1d(model);
		for (var i = 0; i < modellen; i++)
			block_render_model_generate(model[i]);
	}
	else
		block_render_model_generate(model)
}

// Reset wind and brightness
vertex_wave = e_vertex_wave.NONE
vertex_wave_zmin = null
vertex_wave_zmax = null
vertex_brightness = 0

/*block_current = array3D_get(block_obj, build_size, build_pos)
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
		block_render_models_generate(models)
	else // Use script for triangles
		script_execute(models)
}

// Reset wind and brightness
vertex_wave = e_vertex_wave.NONE
vertex_wave_zmin = null
vertex_wave_zmax = null
vertex_brightness = 0*/