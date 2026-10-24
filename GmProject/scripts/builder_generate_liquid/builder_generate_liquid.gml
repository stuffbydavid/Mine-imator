/// @desc Creates a liquid mesh from the surrounding block data.
/// CppGen ArrRef build_pos
/// CppGen ArrRef build_neighbor
/// CppGen ArrRef build_edge
/// CppGen ArrRef block_pos
/// CppGen ArrRef block_face_full
/// CppGen ArrRef block_face_min_depth
/// CppGen ArrRef liquid_match
/// CppGen ArrRef liquid_solid
/// CppGen ArrRef liquid_waterlogged
/// CppGen ArrRef liquid_corner_level
/// CppGen ArrRef liquid_corner_height
/// CppGen ArrRef liquid_corner_pos
/// CppGen ArrRef liquid_side_level
/// CppGen ArrRef liquid_side_height
/// CppGen ArrRef liquid_side_pos
/// CppGen ArrRef liquid_flow
/// CppGen ArrRef liquid_top_uv
/// CppGen ArrRef liquid_slot_still_pos
/// CppGen ArrRef liquid_slot_flow_pos
/// CppGen ArrRef liquid_slot_size
/// CppGen ArrRef liquid_top_mid_uv
/// CppGen ArrRef liquid_from
/// CppGen ArrRef liquid_to
/// CppGen ArrRef liquid_mid
/// CppGen ArrRef liquid_corner_direction
/// CppGen ArrRef liquid_side_corner
/// CppGen ArrRef liquid_side_uv
/// CppGen ArrRef liquid_corner_left_uv
/// CppGen ArrRef liquid_corner_right_uv
/// CppGen ArrRef liquid_bottom_pos

function builder_generate_liquid(waterlogged = false)
{
	// Read block coordinates once for this call
	var blockx, blocky, blockz;
	blockx = build_pos[X]
	blocky = build_pos[Y]
	blockz = build_pos[Z]
	
	// Match adjacent liquid and solid faces
	var allmatch = true;
	for (var f = 0; f < block_faces; f++)
	{
		build_neighbor[X] = blockx
		build_neighbor[Y] = blocky
		build_neighbor[Z] = blockz
		build_neighbor[f div 2] += 1 - 2 * (f mod 2)
		
		liquid_waterlogged[f] = -1
		liquid_match[f] = false
		
		if (!build_edge[f])
		{
			liquid_match[f] = (builder_get_block(build_neighbor[X], build_neighbor[Y], build_neighbor[Z]) = block_current)
			if (!liquid_match[f])
			{
				liquid_waterlogged[f] = bool_to_float(builder_get_waterlogged(build_neighbor[X], build_neighbor[Y], build_neighbor[Z]))
				liquid_match[f] = (liquid_waterlogged[f] = 1)
			}
		}
		
		if (!liquid_match[f])
			allmatch = false
		
		liquid_solid[f] = (block_face_min_depth[f] = e_block_depth.DEPTH0 && block_face_full[f])
	}
	
	// Matching liquid hides every face even when waves are enabled
	if (allmatch)
		return 0

	// Keep wave gaps covered beside liquid above or below
	if (app.project_render_liquid_animation)
	{
		for (var vertical = ZP; vertical <= ZN; vertical++)
		{
			if (!liquid_match[vertical])
				continue
			
			for (var f = XP; f <= YN; f++)
			{
				if (!liquid_solid[f] || build_edge[f])
					continue
				
				build_neighbor[X] = blockx
				build_neighbor[Y] = blocky
				build_neighbor[Z] = blockz
				build_neighbor[f div 2] += 1 - 2 * (f mod 2)
				build_neighbor[Z] += 1 - 2 * (vertical mod 2)
				
				if (builder_get_block(build_neighbor[X], build_neighbor[Y], build_neighbor[Z]) != block_current)
				{
					var model, opposite;
					model = builder_get_render_model(build_neighbor[X], build_neighbor[Y], build_neighbor[Z])
					opposite = f + 1 - 2 * (f mod 2)
					
					liquid_solid[f] = false
					
					if (model != null)
						liquid_solid[f] = (model.face_min_depth[opposite] = e_block_depth.DEPTH0 && model.face_full[opposite])
				}
			}
		}
	}

	// Completely surrounded, no need to render
	var surrounded = liquid_match[ZP];
	for (var f = 0; f < block_faces; f++)
		if (f != ZP && !liquid_match[f] && !liquid_solid[f])
			surrounded = false
	
	if (surrounded)
		return 0
	
	// Prepare only the geometry needed by visible faces
	var showsides, showbottom;
	showsides = false
	showbottom = (!liquid_match[ZN] && !liquid_solid[ZN])
	
	for (var f = XP; f <= YN; f++)
		if (!liquid_match[f] && !liquid_solid[f])
			showsides = true

	// Find texture and buffers to use
	var slot, dep, vbuf, sheetwidth;
	slot = mc_assets.block_liquid_slot_map[?block_current.name]
	dep = mc_res.block_sheet_ani_depth_list[|slot]
	vbuf = (block_current.name = "water" ? e_block_vbuffer.WATER : e_block_vbuffer.ANIMATED)

	if (vbuf = e_block_vbuffer.WATER)
		dep = e_block_depth.DEPTH2

	sheetwidth = minecraft_block_sheet_size[e_block_sheet.ANIMATED][X]
	
	liquid_slot_still_pos[X] = (slot mod sheetwidth) * block_size
	liquid_slot_still_pos[Y] = (slot div sheetwidth) * block_size
	
	slot = mc_assets.block_liquid_slot_map[?"flowing_" + block_current.name]
	
	liquid_slot_flow_pos[X] = (slot mod sheetwidth) * block_size
	liquid_slot_flow_pos[Y] = (slot div sheetwidth) * block_size
	
	for (var a = X; a <= Y; a++)
		liquid_slot_size[a] = 1 / (minecraft_block_sheet_size[e_block_sheet.ANIMATED][a] * block_size)

	// Top face and corner heights
	var topflow, topangle, level, minz, averagez;
	topflow = true
	topangle = 0
	level = (waterlogged ? 0 : block_state_id_current)

	// Enable wave on bottom vertices if there is a liquid block
	if (app.project_render_liquid_animation)
	{
		block_vertex_wave = e_vertex_wave.Z_ONLY
		block_vertex_wave_zmin = (liquid_match[ZN] ? null : block_pos[Z])
	}
	
	// Falling liquid fills the block
	if (level div 8 || liquid_match[ZP])
	{
		for (var c = 0; c < 4; c++)
			liquid_corner_height[c] = block_size
		
		minz = block_size
		averagez = block_size
		topflow = false
	}
	else
	{
		for (var f = XP; f <= YN; f++)
		{
			liquid_side_level[f] = level
			liquid_corner_level[f] = level
			liquid_flow[f] = 0
		}

		if (!waterlogged)
		{
			// Read side levels, treating liquid above as full height
			for (var f = XP; f <= YN; f++)
			{
				build_neighbor[X] = blockx
				build_neighbor[Y] = blocky
				build_neighbor[Z] = blockz
				build_neighbor[f div 2] += 1 - 2 * (f mod 2)
				
				if (!build_edge[f] && liquid_waterlogged[f] = -1)
					liquid_waterlogged[f] = bool_to_float(builder_get_waterlogged(build_neighbor[X], build_neighbor[Y], build_neighbor[Z]))
				
				if (!build_edge[f] && liquid_waterlogged[f] = 0)
				{
					if (!build_edge[ZP] && builder_get_block(build_neighbor[X], build_neighbor[Y], build_neighbor[Z] + 1) = block_current)
						liquid_side_level[f] = 8
					else if (liquid_match[f])
						liquid_side_level[f] = builder_get_state_id(build_neighbor[X], build_neighbor[Y], build_neighbor[Z])
				}
			}

			// Read corner levels clockwise from the negative X/Y corner
			for (var c = 0; c < 4; c++)
			{
				var xdir, ydir;
				xdir = liquid_corner_direction[c][X]
				ydir = liquid_corner_direction[c][Y]
				build_neighbor[X] = blockx + 1 - 2 * (xdir mod 2)
				build_neighbor[Y] = blocky + 1 - 2 * (ydir mod 2)
				build_neighbor[Z] = blockz
				
				if (!build_edge[xdir] && !build_edge[ydir] && !builder_get_waterlogged(build_neighbor[X], build_neighbor[Y], build_neighbor[Z]))
				{
					if (!build_edge[ZP] && builder_get_block(build_neighbor[X], build_neighbor[Y], build_neighbor[Z] + 1) = block_current)
						liquid_corner_level[c] = 8
					else if (builder_get_block(build_neighbor[X], build_neighbor[Y], build_neighbor[Z]) = block_current)
						liquid_corner_level[c] = builder_get_state_id(build_neighbor[X], build_neighbor[Y], build_neighbor[Z])
				}
			}
		}

		// Calculate flow direction and side heights
		var myz = 14 - (level / 7) * 13.5;
		for (var f = XP; f <= YN; f++)
		{
			if (liquid_side_level[f] mod 8 < level)
				liquid_flow[f + 1 - 2 * (f mod 2)]++
			else if (liquid_side_level[f] mod 8 > level)
				liquid_flow[f]++
			
			liquid_side_height[f] = (liquid_side_level[f] div 8 ? block_size : 14 - (liquid_side_level[f] / 7) * 13.5)
		}

		// Each corner takes the highest adjoining level
		minz = block_size
		averagez = 0
		for (var c = 0; c < 4; c++)
		{
			liquid_corner_height[c] = (liquid_corner_level[c] div 8 ? block_size : 14 - (liquid_corner_level[c] / 7) * 13.5)
			liquid_corner_height[c] = max(liquid_corner_height[c], liquid_side_height[liquid_corner_direction[c][X]], liquid_side_height[liquid_corner_direction[c][Y]], myz)
			
			minz = min(minz, liquid_corner_height[c])
			averagez += liquid_corner_height[c] / 4
		}

		// Set texture orientation
		if ((!liquid_flow[XN] && !liquid_flow[XP] && !liquid_flow[YN] && !liquid_flow[YP]) ||
			(liquid_flow[XN] && liquid_flow[XP] && liquid_flow[YN] && liquid_flow[YP]) ||
			(liquid_flow[XN] && liquid_flow[XP] && !liquid_flow[YN] && !liquid_flow[YP]) ||
			(!liquid_flow[XN] && !liquid_flow[XP] && liquid_flow[YN] && liquid_flow[YP]))
			topflow = false
		else if (liquid_flow[XN] && liquid_flow[XP] && liquid_flow[YP])
			topangle = 0
		else if (liquid_flow[XN] && liquid_flow[XP] && liquid_flow[YN])
			topangle = 180
		else if (liquid_flow[XP] && liquid_flow[YN] && liquid_flow[YP])
			topangle = 90
		else if (liquid_flow[XN] && liquid_flow[YN] && liquid_flow[YP])
			topangle = 270
		else if (liquid_flow[XN] && liquid_flow[YN])
			topangle = 180 + 45 + 10 * (liquid_flow[XN] - 1) - 10 * (liquid_flow[YN] - 1)
		else if (liquid_flow[XP] && liquid_flow[YN])
			topangle = 180 - 45 + 10 * (liquid_flow[YN] - 1) - 10 * (liquid_flow[XP] - 1)
		else if (liquid_flow[XN] && liquid_flow[YP])
			topangle = 270 + 45 + 10 * (liquid_flow[YP] - 1) - 10 * (liquid_flow[XN] - 1)
		else if (liquid_flow[XP] && liquid_flow[YP])
			topangle = 45 + 10 * (liquid_flow[XP] - 1) - 10 * (liquid_flow[YP] - 1)
		else if (liquid_flow[YP])
			topangle = 0
		else if (liquid_flow[XP])
			topangle = 90
		else if (liquid_flow[YN])
			topangle = 180
		else if (liquid_flow[XN])
			topangle = 270
	}

	// Texture coordinates clockwise from the top-left corner
	for (var c = 0; c < 4; c++)
	{
		if (showsides)
		{
			liquid_side_uv[c][X] = (c = 1 || c = 2 ? block_size : 0)
			liquid_side_uv[c][Y] = (c < 2 ? block_size - minz : block_size)
			liquid_corner_left_uv[c][X] = 0
			liquid_corner_right_uv[c][X] = block_size
			liquid_corner_left_uv[c][Y] = block_size - liquid_corner_height[c]
			liquid_corner_right_uv[c][Y] = block_size - liquid_corner_height[c]
		}
		
		liquid_top_uv[c][X] = (c = 1 || c = 2 ? block_size : 0)
		liquid_top_uv[c][Y] = (c >= 2 ? block_size : 0)
	}

	// Rotate the top texture without allocating new vectors
	if (topangle != 0)
	{
		var p = (mod_fix(topangle, 90) / 90) * block_size;
		liquid_top_uv[0][X] = p
		liquid_top_uv[1][Y] = p
		liquid_top_uv[2][X] = block_size - p
		liquid_top_uv[3][Y] = block_size - p
		
		repeat (topangle div 90)
		{
			for (var a = X; a <= Y; a++)
			{
				var first = liquid_top_uv[0][a];
				for (var c = 0; c < 3; c++)
					liquid_top_uv[c][a] = liquid_top_uv[c + 1][a]
				
				liquid_top_uv[3][a] = first
			}
		}
	}

	// Transform texture coordinates to the animated sheet
	for (var a = X; a <= Y; a++)
	{
		var toppos = (topflow ? liquid_slot_flow_pos[a] : liquid_slot_still_pos[a]);
		liquid_top_mid_uv[a] = (block_half_size + toppos) * liquid_slot_size[a]
		
		for (var c = 0; c < 4; c++)
		{
			if (showsides)
			{
				liquid_side_uv[c][a] = (liquid_side_uv[c][a] + liquid_slot_flow_pos[a]) * liquid_slot_size[a]
				liquid_corner_left_uv[c][a] = (liquid_corner_left_uv[c][a] + liquid_slot_flow_pos[a]) * liquid_slot_size[a]
				liquid_corner_right_uv[c][a] = (liquid_corner_right_uv[c][a] + liquid_slot_flow_pos[a]) * liquid_slot_size[a]
			}
			
			liquid_top_uv[c][a] = (liquid_top_uv[c][a] + toppos) * liquid_slot_size[a]
		}
	}

	// Position the mesh and inset waterlogged sides
	for (var a = X; a <= Y; a++)
	{
		liquid_from[a] = block_pos[a]
		liquid_to[a] = block_pos[a] + block_size
		liquid_mid[a] = block_pos[a] + block_half_size
		
		if (waterlogged)
		{
			if (!liquid_match[a * 2])
				liquid_to[a] -= 0.05
			
			if (!liquid_match[a * 2 + 1])
				liquid_from[a] += 0.05
		}
	}
	
	liquid_from[Z] = floor(block_pos[Z])
	liquid_to[Z] = liquid_from[Z] + minz
	liquid_mid[Z] = liquid_from[Z] + averagez
	
	for (var c = 0; c < 4; c++)
	{
		for (var a = X; a <= Y; a++)
		{
			liquid_corner_pos[c][a] = (liquid_corner_direction[c][a] mod 2 ? liquid_from[a] : liquid_to[a])
			
			if (showsides)
				liquid_side_pos[c][a] = liquid_corner_pos[c][a]
			
			if (showsides || showbottom)
				liquid_bottom_pos[c][a] = liquid_corner_pos[c][a]
		}
		
		liquid_corner_pos[c][Z] = liquid_from[Z] + liquid_corner_height[c]
		
		if (showsides)
			liquid_side_pos[c][Z] = liquid_to[Z]
		
		if (showsides || showbottom)
			liquid_bottom_pos[c][Z] = liquid_from[Z]
	}

	// Generate side quads and the triangle above each one
	var index = dep * e_block_vbuffer.amount + vbuf;
	block_vbuffer_current = block_mesh.block_vbuffer[@index]
	block_vertex_emissive = block_current.emissive
	
	for (var f = XP; f <= YN; f++)
	{
		if (liquid_match[f] || liquid_solid[f])
			continue

		var first, second, peak, right;
		first = liquid_side_corner[f][X]
		second = liquid_side_corner[f][Y]
		
		builder_add_face(
			liquid_side_pos[first], liquid_side_pos[second], liquid_bottom_pos[second], liquid_bottom_pos[first],
			liquid_side_uv[0], liquid_side_uv[1], liquid_side_uv[2], liquid_side_uv[3],
			null
		)
		
		right = (liquid_corner_height[second] > liquid_corner_height[first])
		peak = (right ? second : first)
		
		builder_add_triangle(
			liquid_side_pos[second], liquid_side_pos[first], liquid_corner_pos[peak],
			liquid_side_uv[1], liquid_side_uv[0], right ? liquid_corner_right_uv[peak] : liquid_corner_left_uv[peak],
			null
		)
	}

	// Generate the top fan and bottom face
	if (!liquid_match[ZP])
	{
		for (var c = 0; c < 4; c++)
		{
			var next = (c + 1) mod 4;
			builder_add_triangle(
				liquid_mid, liquid_corner_pos[c], liquid_corner_pos[next],
				liquid_top_mid_uv, liquid_top_uv[c], liquid_top_uv[next],
				null
			)
		}
	}
	if (showbottom)
	{
		builder_add_face(
			liquid_bottom_pos[3], liquid_bottom_pos[2], liquid_bottom_pos[1], liquid_bottom_pos[0],
			liquid_top_uv[3], liquid_top_uv[2], liquid_top_uv[1], liquid_top_uv[0],
			null
		)
	}
	
}
