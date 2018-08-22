/// builder_generate()
/// @desc Generate triangles from the block render models.

block_current = builder_get(block_obj, build_pos_x, build_pos_y, build_pos_z)
if (block_current = null)
	return 0
	
build_edge_xp = (build_pos_x = build_size_x - 1)
build_edge_xn = (build_pos_x = 0)
build_edge_yp = (build_pos_y = build_size_y - 1)
build_edge_yn = (build_pos_y = 0)
build_edge_zp = (build_pos_z = build_size_z - 1)
build_edge_zn = (build_pos_z = 0)

// Check edges for culling

// X+
block_face_full_xp = false
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
	var othermodel = builder_get_render_model(build_pos_x + 1, build_pos_y, build_pos_z);
	if (is_array(othermodel))
		othermodel = othermodel[0]
	if (othermodel != null)
	{
		block_face_full_xp = othermodel.face_full_xn
		block_face_min_xp = othermodel.face_min_xn
		block_face_max_xp = othermodel.face_max_xn
		block_face_min_depth_xp = othermodel.face_min_depth_xn
	}
}

// X-
block_face_full_xn = false
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
	var othermodel = builder_get_render_model(build_pos_x - 1, build_pos_y, build_pos_z);
	if (is_array(othermodel))
		othermodel = othermodel[0]
	if (othermodel != null)
	{
		block_face_full_xn = othermodel.face_full_xp
		block_face_min_xn = othermodel.face_min_xp
		block_face_max_xn = othermodel.face_max_xp
		block_face_min_depth_xn = othermodel.face_min_depth_xp
	}
}

// Y+
block_face_full_yp = false
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
	var othermodel = builder_get_render_model(build_pos_x, build_pos_y + 1, build_pos_z);
	if (is_array(othermodel))
		othermodel = othermodel[0]
	if (othermodel != null)
	{
		block_face_full_yp = othermodel.face_full_yn
		block_face_min_yp = othermodel.face_min_yn
		block_face_max_yp = othermodel.face_max_yn
		block_face_min_depth_yp = othermodel.face_min_depth_yn
	}
}

// Y-
block_face_full_yn = false
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
	var othermodel = builder_get_render_model(build_pos_x, build_pos_y - 1, build_pos_z);
	if (is_array(othermodel))
		othermodel = othermodel[0]
	if (othermodel != null)
	{
		block_face_full_yn = othermodel.face_full_yp
		block_face_min_yn = othermodel.face_min_yp
		block_face_max_yn = othermodel.face_max_yp
		block_face_min_depth_yn = othermodel.face_min_depth_yp
	}
}

// Z+
block_face_full_zp = false
block_face_min_depth_zp = null
if (!build_edge_zp)
{
	var othermodel = builder_get_render_model(build_pos_x, build_pos_y, build_pos_z + 1);
	if (is_array(othermodel))
		othermodel = othermodel[0]
	if (othermodel != null)
	{
		block_face_full_zp = othermodel.face_full_zn
		block_face_min_zp = othermodel.face_min_zn
		block_face_max_zp = othermodel.face_max_zn
		block_face_min_depth_zp = othermodel.face_min_depth_zn
	}
}

// Z-
block_face_full_zn = false
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
	var othermodel = builder_get_render_model(build_pos_x, build_pos_y, build_pos_z - 1);
	if (is_array(othermodel))
		othermodel = othermodel[0]
	if (othermodel != null)
	{
		block_face_full_zn = othermodel.face_full_zp
		block_face_min_zn = othermodel.face_min_zp
		block_face_max_zn = othermodel.face_max_zp
		block_face_min_depth_zn = othermodel.face_min_depth_zp
	}
}

// Completely surrounded by solids, skip
if (block_face_min_depth_xp = e_block_depth.DEPTH0 && block_face_full_xp &&
	block_face_min_depth_xn = e_block_depth.DEPTH0 && block_face_full_xn &&
	block_face_min_depth_yp = e_block_depth.DEPTH0 && block_face_full_yp &&
	block_face_min_depth_yn = e_block_depth.DEPTH0 && block_face_full_yn &&
	block_face_min_depth_zp = e_block_depth.DEPTH0 && block_face_full_zp &&
	block_face_min_depth_zn = e_block_depth.DEPTH0 && block_face_full_zn)
	return 0

// Current state ID
block_state_id_current = builder_get(block_state_id, build_pos_x, build_pos_y, build_pos_z);

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

// Run a block-specific script for generating a mesh if available
if (block_current.generate_script > -1)
	script_execute(block_current.generate_script)
else
{
	// Set wind and brightness
	vertex_brightness = null
	vertex_wave = block_current.wind_axis
	if (block_current.wind_zmin != null)
		vertex_wave_zmin = block_pos_z + block_current.wind_zmin
	vertex_light_bleeding = block_current.light_bleeding
		
	// Requires other render models for states
	if (block_current.require_models)
		builder_set_model(true)

	// Get model	
	var model = builder_get_render_model(build_pos_x, build_pos_y, build_pos_z);
	if (model != null)
	{
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
}

// Reset wind, brightness, and light bleeding
vertex_wave = e_vertex_wave.NONE
vertex_wave_zmin = null
vertex_wave_zmax = null
vertex_brightness = 0
vertex_light_bleeding = 0