/// builder_generate()
/// @desc Generate triangles from the block render models.

block_current = array3D_get(block_obj, build_size_z, build_pos_x, build_pos_y, build_pos_z)
if (block_current = null)
	return 0

block_state_id_current = array3D_get(block_state_id, build_size_z, build_pos_x, build_pos_y, build_pos_z);

// Block position
block_pos_x = build_pos_x * block_size
block_pos_y = build_pos_y * block_size
block_pos_z = build_pos_z * block_size
block_color = null

// Random X & Y offset
if (block_current.random_offset && build_size_x * build_size_y * build_size_z > 1)
{
	random_set_seed(build_pos_x * build_size_y * build_size_z + build_pos_y * build_size_z + build_pos_z)
	block_pos_x += irandom_range(-4, 4)
	block_pos_y += irandom_range(-4, 4)
}

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
	if (is_array(othermodel))
		othermodel = othermodel[0]
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
	if (is_array(othermodel))
		othermodel = othermodel[0]
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
	if (is_array(othermodel))
		othermodel = othermodel[0]
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
	if (is_array(othermodel))
		othermodel = othermodel[0]
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
	if (is_array(othermodel))
		othermodel = othermodel[0]
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
	if (is_array(othermodel))
		othermodel = othermodel[0]
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

// Run a block-specific script for generating a mesh if available
if (block_current.generate_script > -1)
{
	build_pos = point3D(build_pos_x, build_pos_y, build_pos_z)
	build_edge[e_dir.EAST]	= (build_pos_x = build_size_x - 1)
	build_edge[e_dir.WEST]	= (build_pos_x = 0)
	build_edge[e_dir.SOUTH] = (build_pos_y = build_size_y - 1)
	build_edge[e_dir.NORTH] = (build_pos_y = 0)
	build_edge[e_dir.UP]	= (build_pos_z = build_size_z - 1)
	build_edge[e_dir.DOWN]	= (build_pos_z = 0)
					
	script_execute(block_current.generate_script)
}
else
{
	// Requires other render models for states
	if (block_current.require_models)
		builder_set_model()

	// Get model	
	var model = array3D_get(block_render_model, build_size_z, build_pos_x, build_pos_y, build_pos_z);
	if (model = null)
		return 0

	// Set wind
	vertex_wave = block_current.wind_axis
	if (block_current.wind_zmin != null)
		vertex_wave_zmin = block_pos_z + block_current.wind_zmin
	
	// Generate render model
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