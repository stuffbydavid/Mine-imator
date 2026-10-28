/// @desc Generate triangles from the block render models.
/// CppGen ArrRef build_pos
/// CppGen ArrRef build_size
/// CppGen ArrRef build_edge
/// CppGen ArrRef block_pos
/// CppGen ArrRef block_face_full
/// CppGen ArrRef block_face_min
/// CppGen ArrRef block_face_max
/// CppGen ArrRef block_face_min_depth

function builder_generate()
{
	// Read block coordinates once for this call
	var blockx, blocky, blockz, sizex, sizey, sizez;
	blockx = build_pos[X]
	blocky = build_pos[Y]
	blockz = build_pos[Z]
	sizex = build_size[X]
	sizey = build_size[Y]
	sizez = build_size[Z]
	
	block_current = builder_get_block(blockx, blocky, blockz)
	if (block_current = null)
		return 0
	
	if (mc_builder.build_multithreaded != null)
	{
		if (block_current.multithreaded != mc_builder.build_multithreaded)
		{
			block_multithreaded_skip = true
			return 0
		}
	}
	
	// Check neighboring faces and selection boundaries for culling
	build_edge[XP] = (blockx = sizex - 1)
	build_edge[XN] = (blockx = 0)
	build_edge[YP] = (blocky = sizey - 1)
	build_edge[YN] = (blocky = 0)
	build_edge[ZP] = (blockz = sizez - 1)
	build_edge[ZN] = (blockz = 0)
	
	var solidfaces = 0;
	for (var f = 0; f < block_faces; f++)
	{
		var othermodel = null;
		if (!build_edge[f])
		{
			var neighborx, neighbory, neighborz;
			neighborx = blockx
			neighbory = blocky
			neighborz = blockz
			
			switch (f)
			{
				case XP: neighborx = blockx + 1; break
				case XN: neighborx = blockx - 1; break
				case YP: neighbory = blocky + 1; break
				case YN: neighbory = blocky - 1; break
				case ZP: neighborz = blockz + 1; break
				case ZN: neighborz = blockz - 1; break
			}

			othermodel = builder_get_render_model(neighborx, neighbory, neighborz)
		}
		
		if (othermodel != null)
			builder_set_neighbor_face(othermodel, f)
		else
		{
			// Initialize missing neighbors without clearing faces that will be copied
			block_face_full[f] = false
			block_face_min[f] = null
			block_face_max[f] = null
			block_face_min_depth[f] = null
			
			// Keep the top boundary open when removing scenery edges
			if (build_edge[f] && !mc_builder.build_edges && f != ZP)
			{
				block_face_full[f] = true
				block_face_min_depth[f] = e_block_depth.DEPTH0
			}
		}

		if (block_face_min_depth[f] = e_block_depth.DEPTH0 && block_face_full[f])
			solidfaces++
	}

	// Completely surrounded by solids, skip
	if (solidfaces = block_faces)
		return 0
	
	// Current state ID
	block_state_id_current = builder_get_state_id(blockx, blocky, blockz)
	
	// Block position
	block_pos[X] = blockx * block_size
	block_pos[Y] = blocky * block_size
	block_pos[Z] = blockz * block_size
	block_color_index = 0
	
	// Run a block-specific script for generating a mesh if available
	if (block_current.generate_script > -1)
		script_execute(block_current.generate_script)
	else
	{
		var model = null;
		if (block_current.require_models) // Requires other render models for states (returns model(s))
			model = builder_set_model(true)
		else
		{
			// Get modelindex (0 for air, <0 for multi-part, >0 for single)
			var modelindex = builder_get_render_model_index(blockx, blocky, blockz);
			if (modelindex > 0)
				model = modelindex
			else if (modelindex < 0)
				model = builder_get_render_model_multipart(blockx, blocky, blockz, -modelindex)
		}
		
		// Get single model
		var singlemodel = null;
		if (is_array(model))
			singlemodel = block_rendermodels[model[0]]
		else if (model > 0)
			singlemodel = block_rendermodels[model]
		
		if (singlemodel != null)
		{
			// Random X & Y offset
			if ((singlemodel.random_offset && (build_size_total > 1)) || (singlemodel.random_offset_xy && (build_size_xy > 1)))
			{
				if (singlemodel.random_offset)
					block_pos[Z] += builder_irandom_range(-3, 0, Z)
				
				block_pos[X] += builder_irandom_range(-4, 4, X, singlemodel.random_offset)
				block_pos[Y] += builder_irandom_range(-4, 4, Y, singlemodel.random_offset)
			}
		}
		
		// Set wind and brightness
		block_vertex_emissive = null
		block_vertex_wave = block_current.wind_axis
		if (block_current.wind_zmin != null)
			block_vertex_wave_zmin = block_pos[Z] + block_current.wind_zmin
		block_vertex_subsurface = block_current.subsurface
		
		// Generate render modelindex(s)
		if (is_array(model))
		{
			for (var i = 0; i < array_length(model); i++)
				block_render_model_generate(block_rendermodels[model[i]])
		}
		else if (model > 0)
			block_render_model_generate(block_rendermodels[model])
	}
	
	// Reset wind, brightness, and light bleeding
	block_vertex_wave = e_vertex_wave.NONE
	block_vertex_wave_zmin = null
	block_vertex_wave_zmax = null
	block_vertex_emissive = 0
	block_vertex_subsurface = 0
	
	// Waterlogged
	if (builder_get_waterlogged(blockx, blocky, blockz))
	{
		// Restore block position in case of offset
		block_pos[X] = blockx * block_size
		block_pos[Y] = blocky * block_size
		block_pos[Z] = blockz * block_size
		
		block_current = mc_assets.block_name_map[?"water"]
		builder_generate_liquid(true)
		
		block_vertex_wave = e_vertex_wave.NONE
		block_vertex_wave_zmin = null
		block_vertex_wave_zmax = null
		block_vertex_emissive = 0
		block_vertex_subsurface = 0
	}
}
