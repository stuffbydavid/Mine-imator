/// block_generate_liquid(waterlogged)
/// @arg waterlogged
/// @desc Creates a liquid mesh from the surrounding block data.

function block_generate_liquid(waterlogged = false)
{
	var matchxp, matchxn, matchyp, matchyn, matchzp, matchzn;
	var solidxp, solidxn, solidyp, solidyn, solidzp, solidzn;
	matchxp = (!build_edge_xp && builder_get_block(build_pos_x + 1, build_pos_y, build_pos_z) = block_current)
	matchxn = (!build_edge_xn && builder_get_block(build_pos_x - 1, build_pos_y, build_pos_z) = block_current)
	matchyp = (!build_edge_yp && builder_get_block(build_pos_x, build_pos_y + 1, build_pos_z) = block_current)
	matchyn = (!build_edge_yn && builder_get_block(build_pos_x, build_pos_y - 1, build_pos_z) = block_current)
	matchzp = (!build_edge_zp && builder_get_block(build_pos_x, build_pos_y, build_pos_z + 1) = block_current)
	matchzn = (!build_edge_zn && builder_get_block(build_pos_x, build_pos_y, build_pos_z - 1) = block_current)
	solidxp = (block_face_min_depth_xp = e_block_depth.DEPTH0 && block_face_full_xp)
	solidxn = (block_face_min_depth_xn = e_block_depth.DEPTH0 && block_face_full_xn)
	solidyp = (block_face_min_depth_yp = e_block_depth.DEPTH0 && block_face_full_yp)
	solidyn = (block_face_min_depth_yn = e_block_depth.DEPTH0 && block_face_full_yn)
	solidzp = (block_face_min_depth_zp = e_block_depth.DEPTH0 && block_face_full_zp)
	solidzn = (block_face_min_depth_zn = e_block_depth.DEPTH0 && block_face_full_zn)
	
	// Waterlogged: No water around, no need to render
	//if (waterlogged && !matchxp && !matchxn && !matchyp && !matchyn && !matchzp && !matchzn)
	//	return 0
	
	// Match with waterlogged
	matchxp = (matchxp || (!build_edge_xp && builder_get_waterlogged(build_pos_x + 1, build_pos_y, build_pos_z)))
	matchxn = (matchxn || (!build_edge_xn && builder_get_waterlogged(build_pos_x - 1, build_pos_y, build_pos_z)))
	matchyp = (matchyp || (!build_edge_yp && builder_get_waterlogged(build_pos_x, build_pos_y + 1, build_pos_z)))
	matchyn = (matchyn || (!build_edge_yn && builder_get_waterlogged(build_pos_x, build_pos_y - 1, build_pos_z)))
	matchzp = (matchzp || (!build_edge_zp && builder_get_waterlogged(build_pos_x, build_pos_y, build_pos_z + 1)))
	matchzn = (matchzn || (!build_edge_zn && builder_get_waterlogged(build_pos_x, build_pos_y, build_pos_z - 1)))
		
	// To fix wave "gaps"
	if (app.project_render_liquid_animation)
	{
		var model;
		if (matchzp)
		{
			if (solidxp && !build_edge_xp && builder_get_block(build_pos_x + 1, build_pos_y, build_pos_z + 1) != block_current)
			{
				solidxp = false
				model = builder_get_render_model(build_pos_x + 1, build_pos_y, build_pos_z + 1)
				if (model != null)
					solidxp = (model.face_min_depth_xn = e_block_depth.DEPTH0 && model.face_full_xn)
			}
			
			if (solidxn && !build_edge_xn && builder_get_block(build_pos_x - 1, build_pos_y, build_pos_z + 1) != block_current)
			{
				solidxn = false
				model = builder_get_render_model(build_pos_x - 1, build_pos_y, build_pos_z + 1)
				if (model != null)
					solidxn = (model.face_min_depth_xp = e_block_depth.DEPTH0 && model.face_full_xp)
			}
			
			if (solidyp && !build_edge_yp && builder_get_block(build_pos_x, build_pos_y + 1, build_pos_z + 1) != block_current)
			{
				solidyp = false
				model = builder_get_render_model(build_pos_x, build_pos_y + 1, build_pos_z + 1)
				if (model != null)
					solidyp = (model.face_min_depth_yn = e_block_depth.DEPTH0 && model.face_full_yn)
			}
			
			if (solidyn && !build_edge_yn && builder_get_block(build_pos_x, build_pos_y - 1, build_pos_z + 1) != block_current)
			{
				solidyn = false
				model = builder_get_render_model(build_pos_x, build_pos_y - 1, build_pos_z + 1)
				if (model != null)
					solidyn = (model.face_min_depth_yp = e_block_depth.DEPTH0 && model.face_full_yp)
			}
		}
		
		if (matchzn)
		{
			if (solidxp && !build_edge_xp && builder_get_block(build_pos_x + 1, build_pos_y, build_pos_z - 1) != block_current)
			{
				solidxp = false
				model = builder_get_render_model(build_pos_x + 1, build_pos_y, build_pos_z - 1)
				if (model != null)
					solidxp = (model.face_min_depth_xn = e_block_depth.DEPTH0 && model.face_full_xn)
			}
			
			if (solidxn && !build_edge_xn && builder_get_block(build_pos_x - 1, build_pos_y, build_pos_z - 1) != block_current)
			{
				solidxn = false
				model = builder_get_render_model(build_pos_x - 1, build_pos_y, build_pos_z - 1)
				if (model != null)
					solidxn = (model.face_min_depth_xp = e_block_depth.DEPTH0 && model.face_full_xp)
			}
			
			if (solidyp && !build_edge_yp && builder_get_block(build_pos_x, build_pos_y + 1, build_pos_z - 1) != block_current)
			{
				solidyp = false
				model = builder_get_render_model(build_pos_x, build_pos_y + 1, build_pos_z - 1)
				if (model != null)
					solidyp = (model.face_min_depth_yn = e_block_depth.DEPTH0 && model.face_full_yn)
			}
			
			if (solidyn && !build_edge_yn && builder_get_block(build_pos_x, build_pos_y - 1, build_pos_z - 1) != block_current)
			{
				solidyn = false
				model = builder_get_render_model(build_pos_x, build_pos_y - 1, build_pos_z - 1)
				if (model != null)
					solidyn = (model.face_min_depth_yp = e_block_depth.DEPTH0 && model.face_full_yp)
			}
		}
	}
	
	// Completely surrounded, no need to render
	if ((matchxp || solidxp) && (matchxn || solidxn) && 
		(matchyp || solidyp) && (matchyn || solidyn) && 
		matchzp && (matchzn || solidzn))
		return 0
	
	// Find texture and buffers to use
	var slot, dep, vbuf, sheetwidth, sheetheight;
	var slotstillposx, slotstillposy, slotstillsizex, slotstillsizey;
	var slotflowposx, slotflowposy, slotflowsizex, slotflowsizey;
	
	// Still texture
	slot = mc_assets.block_liquid_slot_map[?block_current.name]
	dep = mc_res.block_sheet_ani_depth_list[|slot]
	
	if (block_current.name = "water")
		vbuf = e_block_vbuffer.WATER
	else
		vbuf = e_block_vbuffer.ANIMATED
	
	sheetwidth = block_sheet_ani_width
	sheetheight = block_sheet_ani_height
	slotstillposx = (slot mod sheetwidth) * block_size
	slotstillposy = (slot div sheetwidth) * block_size
	slotstillsizex = 1 / (sheetwidth * block_size)
	slotstillsizey = 1 / (sheetheight * block_size)
	
	// Flow texture
	slot = mc_assets.block_liquid_slot_map[?"flowing_" + block_current.name]
	slotflowposx = (slot mod sheetwidth) * block_size
	slotflowposy = (slot div sheetwidth) * block_size
	slotflowsizex = 1 / (sheetwidth * block_size)
	slotflowsizey = 1 / (sheetheight * block_size)
	
	// Top face
	var topflow, topangle;
	topflow = true
	topangle = 0
	
	// Corners
	var level = (waterlogged ? 0 : block_state_id_current);
	var corner0z, corner1z, corner2z, corner3z, minz, averagez;
	
	// Wave
	if (app.project_render_liquid_animation)
	{
		block_vertex_wave = e_vertex_wave.Z_ONLY
		
		// Enable wave on bottom vertices if there is a liquid block
		if (matchzn)
			block_vertex_wave_zmin = null
		else
			block_vertex_wave_zmin = block_pos_z
	}
	
	// Color
	block_vertex_rgb = c_white
	block_vertex_alpha = 1
	
	// Falling
	if (level div 8 || matchzp)
	{
		corner0z = block_size
		corner1z = block_size
		corner2z = block_size
		corner3z = block_size
		minz = block_size
		averagez = block_size
		topflow = false
	}
	else
	{
		// Level at sides
		var sidelevelxp, sidelevelxn, sidelevelyp, sidelevelyn;
		sidelevelxp = level
		sidelevelxn = level
		sidelevelyp = level
		sidelevelyn = level
		
		// Level at corners
		var corner0level, corner1level, corner2level, corner3level;
		corner0level = level
		corner1level = level
		corner2level = level
		corner3level = level
		
		if (!waterlogged)
		{
			// Side levels
			if (!build_edge_xp && !builder_get_waterlogged(build_pos_x + 1, build_pos_y, build_pos_z))
			{
				if (!build_edge_zp && builder_get_block(build_pos_x + 1, build_pos_y, build_pos_z + 1) = block_current)
					sidelevelxp = 8	
				else if (matchxp)
					sidelevelxp = builder_get_state_id(build_pos_x + 1, build_pos_y, build_pos_z)
			}
			
			if (!build_edge_xn && !builder_get_waterlogged(build_pos_x - 1, build_pos_y, build_pos_z))
			{
				if (!build_edge_zp && builder_get_block(build_pos_x - 1, build_pos_y, build_pos_z + 1) = block_current)
					sidelevelxn = 8
				else if (matchxn)
					sidelevelxn = builder_get_state_id(build_pos_x - 1, build_pos_y, build_pos_z)
			}
			
			if (!build_edge_yp && !builder_get_waterlogged(build_pos_x, build_pos_y + 1, build_pos_z))
			{
				if (!build_edge_zp && builder_get_block(build_pos_x, build_pos_y + 1, build_pos_z + 1) = block_current)
					sidelevelyp = 8
				else if (matchyp)
					sidelevelyp = builder_get_state_id(build_pos_x, build_pos_y + 1, build_pos_z)
			}
			
			if (!build_edge_yn && !builder_get_waterlogged(build_pos_x, build_pos_y - 1, build_pos_z))
			{
				if (!build_edge_zp && builder_get_block(build_pos_x, build_pos_y - 1, build_pos_z + 1) = block_current)
					sidelevelyn = 8
				else if (matchyn)
					sidelevelyn = builder_get_state_id(build_pos_x, build_pos_y - 1, build_pos_z)
			}
			
			// Corner levels
			if (!build_edge_xn && !build_edge_yn && !builder_get_waterlogged(build_pos_x - 1, build_pos_y - 1, build_pos_z))
			{
				if (!build_edge_zp && builder_get_block(build_pos_x - 1, build_pos_y - 1, build_pos_z + 1) = block_current)
					corner0level = 8
				else if (builder_get_block(build_pos_x - 1, build_pos_y - 1, build_pos_z) = block_current)
					corner0level = builder_get_state_id(build_pos_x - 1, build_pos_y - 1, build_pos_z)
			}
			
			if (!build_edge_xp && !build_edge_yn && !builder_get_waterlogged(build_pos_x + 1, build_pos_y - 1, build_pos_z))
			{
				if (!build_edge_zp && builder_get_block(build_pos_x + 1, build_pos_y - 1, build_pos_z + 1) = block_current)
					corner1level = 8
				else if (builder_get_block(build_pos_x + 1, build_pos_y - 1, build_pos_z) = block_current)
					corner1level = builder_get_state_id(build_pos_x + 1, build_pos_y - 1, build_pos_z)
			}
			
			if (!build_edge_xp && !build_edge_yp && !builder_get_waterlogged(build_pos_x + 1, build_pos_y + 1, build_pos_z))
			{
				if (!build_edge_zp && builder_get_block(build_pos_x + 1, build_pos_y + 1, build_pos_z + 1) = block_current)
					corner2level = 8
				else if (builder_get_block(build_pos_x + 1, build_pos_y + 1, build_pos_z) = block_current)
					corner2level = builder_get_state_id(build_pos_x + 1, build_pos_y + 1, build_pos_z)
			}
			
			if (!build_edge_xn && !build_edge_yp && !builder_get_waterlogged(build_pos_x - 1, build_pos_y + 1, build_pos_z))
			{
				if (!build_edge_zp && builder_get_block(build_pos_x - 1, build_pos_y + 1, build_pos_z + 1) = block_current)
					corner3level = 8
				else if (builder_get_block(build_pos_x - 1, build_pos_y + 1, build_pos_z) = block_current)
					corner3level = builder_get_state_id(build_pos_x - 1, build_pos_y + 1, build_pos_z)
			}
		}
		
		// Set top face flow
		var flowxp, flowxn, flowyp, flowyn;
		flowxp = 0
		flowxn = 0
		flowyp = 0
		flowyn = 0
		
		if (sidelevelxp mod 8 < level)
			flowxn++ 
		else if (sidelevelxp mod 8 > level)
			flowxp++
		
		if (sidelevelxn mod 8 < level)
			flowxp++ 
		else if (sidelevelxn mod 8 > level)
			flowxn++
		
		if (sidelevelyp mod 8 < level)
			flowyn++ 
		else if (sidelevelyp mod 8 > level)
			flowyp++
		
		if (sidelevelyn mod 8 < level)
			flowyp++ 
		else if (sidelevelyn mod 8 > level)
			flowyn++
		
		// Set Zs
		var myz, sidezxp, sidezxn, sidezyp, sidezyn;
		myz = 14 - (level / 7) * 13.5
		sidezxp = ((sidelevelxp div 8) ? block_size : (14 - ((sidelevelxp / 7) * 13.5)))
		sidezxn = ((sidelevelxn div 8) ? block_size : (14 - ((sidelevelxn / 7) * 13.5)))
		sidezyp = ((sidelevelyp div 8) ? block_size : (14 - ((sidelevelyp / 7) * 13.5)))
		sidezyn = ((sidelevelyn div 8) ? block_size : (14 - ((sidelevelyn / 7) * 13.5)))
		corner0z = ((corner0level div 8) ? block_size : (14 - ((corner0level / 7) * 13.5)))
		corner1z = ((corner1level div 8) ? block_size : (14 - ((corner1level / 7) * 13.5)))
		corner2z = ((corner2level div 8) ? block_size : (14 - ((corner2level / 7) * 13.5)))
		corner3z = ((corner3level div 8) ? block_size : (14 - ((corner3level / 7) * 13.5)))
		
		// Max corner levels
		corner0z = max(corner0z, sidezxn, sidezyn, myz)
		corner1z = max(corner1z, sidezxp, sidezyn, myz)
		corner2z = max(corner2z, sidezxp, sidezyp, myz)
		corner3z = max(corner3z, sidezxn, sidezyp, myz)
		
		// Set mininum and average
		averagez = (corner0z + corner1z + corner2z + corner3z) / 4
		minz = min(corner0z, corner1z, corner2z, corner3z)
		
		// Set texture orientation
		if ((!flowxn && !flowxp && !flowyn && !flowyp) || 
			(flowxn && flowxp && flowyn && flowyp) || 
			(flowxn && flowxp && !flowyn && !flowyp) || 
			(!flowxn && !flowxp && flowyn && flowyp))
			topflow = false
		else if (flowxn && flowxp && flowyp)
			topangle = 0
		else if (flowxn && flowxp && flowyn)
			topangle = 180
		else if (flowxp && flowyn && flowyp)
			topangle = 90
		else if (flowxn && flowyn && flowyp)
			topangle = 270
		else if (flowxn && flowyn)
			topangle = 180 + 45 + 10 * (flowxn - 1) - 10 * (flowyn - 1)
		else if (flowxp && flowyn)
			topangle = 180 - 45 + 10 * (flowyn - 1) - 10 * (flowxp - 1)
		else if (flowxn && flowyp)
			topangle = 270 + 45 + 10 * (flowyp - 1) - 10 * (flowxn - 1)
		else if (flowxp && flowyp)
			topangle = 45 + 10 * (flowxp - 1) - 10 * (flowyp - 1)
		else if (flowyp)
			topangle = 0
		else if (flowxp)
			topangle = 90
		else if (flowyn)
			topangle = 180
		else if (flowxn)
			topangle = 270
	}
	
	// Texture coordinates (clockwise starting at top-left)
	var sidetex0x, sidetex0y, sidetex1x, sidetex1y, sidetex2x, sidetex2y, sidetex3x, sidetex3y;
	var cornerlefttex0x, cornerlefttex0y, cornerlefttex1x, cornerlefttex1y, cornerlefttex2x, cornerlefttex2y, cornerlefttex3x, cornerlefttex3y;
	var cornerrighttex0x, cornerrighttex0y, cornerrighttex1x, cornerrighttex1y, cornerrighttex2x, cornerrighttex2y, cornerrighttex3x, cornerrighttex3y
	var toptex0x, toptex0y, toptex1x, toptex1y, toptex2x, toptex2y, toptex3x, toptex3y;
	var topmidtexx, topmidtexy;
	
	// Side
	sidetex0x = 0; sidetex0y = block_size - minz
	sidetex1x = block_size; sidetex1y = block_size - minz
	sidetex2x = block_size; sidetex2y = block_size
	sidetex3x = 0; sidetex3y = block_size
	
	// Corner (left side)
	cornerlefttex0x = 0; cornerlefttex0y = block_size - corner0z
	cornerlefttex1x = 0; cornerlefttex1y = block_size - corner1z
	cornerlefttex2x = 0; cornerlefttex2y = block_size - corner2z
	cornerlefttex3x = 0; cornerlefttex3y = block_size - corner3z
	
	// Corner (right side)
	cornerrighttex0x = block_size; cornerrighttex0y = block_size - corner0z
	cornerrighttex1x = block_size; cornerrighttex1y = block_size - corner1z
	cornerrighttex2x = block_size; cornerrighttex2y = block_size - corner2z
	cornerrighttex3x = block_size; cornerrighttex3y = block_size - corner3z
	
	// Top
	if (topangle <> 0)
	{
		var p = (mod_fix(topangle, 90) / 90) * block_size;
		
		toptex0x = p; toptex0y = 0
		toptex1x = block_size; toptex1y = p
		toptex2x = block_size - p; toptex2y = block_size
		toptex3x = 0; toptex3y = block_size - p
		
		repeat (topangle div 90)
		{
			var tmpx, tmpy;
			tmpx = toptex0x; tmpy = toptex0y
			toptex0x = toptex1x; toptex0y = toptex1y
			toptex1x = toptex2x; toptex1y = toptex2y
			toptex2x = toptex3x; toptex2y = toptex3y
			toptex3x = tmpx; toptex3y = tmpy
		}
	}
	else
	{
		toptex0x = 0; toptex0y = 0
		toptex1x = block_size; toptex1y = 0
		toptex2x = block_size; toptex2y = block_size
		toptex3x = 0; toptex3y = block_size
	}
	
	topmidtexx = block_size / 2; topmidtexy = block_size / 2
	
	// Transform to sheet
	sidetex0x = (sidetex0x + slotflowposx) * slotflowsizex; sidetex0y = (sidetex0y + slotflowposy) * slotflowsizey
	sidetex1x = (sidetex1x + slotflowposx) * slotflowsizex; sidetex1y = (sidetex1y + slotflowposy) * slotflowsizey
	sidetex2x = (sidetex2x + slotflowposx) * slotflowsizex; sidetex2y = (sidetex2y + slotflowposy) * slotflowsizey
	sidetex3x = (sidetex3x + slotflowposx) * slotflowsizex; sidetex3y = (sidetex3y + slotflowposy) * slotflowsizey
	
	cornerlefttex0x = (cornerlefttex0x + slotflowposx) * slotflowsizex; cornerlefttex0y = (cornerlefttex0y + slotflowposy) * slotflowsizey
	cornerlefttex1x = (cornerlefttex1x + slotflowposx) * slotflowsizex; cornerlefttex1y = (cornerlefttex1y + slotflowposy) * slotflowsizey
	cornerlefttex2x = (cornerlefttex2x + slotflowposx) * slotflowsizex; cornerlefttex2y = (cornerlefttex2y + slotflowposy) * slotflowsizey
	cornerlefttex3x = (cornerlefttex3x + slotflowposx) * slotflowsizex; cornerlefttex3y = (cornerlefttex3y + slotflowposy) * slotflowsizey
	
	cornerrighttex0x = (cornerrighttex0x + slotflowposx) * slotflowsizex; cornerrighttex0y = (cornerrighttex0y + slotflowposy) * slotflowsizey
	cornerrighttex1x = (cornerrighttex1x + slotflowposx) * slotflowsizex; cornerrighttex1y = (cornerrighttex1y + slotflowposy) * slotflowsizey
	cornerrighttex2x = (cornerrighttex2x + slotflowposx) * slotflowsizex; cornerrighttex2y = (cornerrighttex2y + slotflowposy) * slotflowsizey
	cornerrighttex3x = (cornerrighttex3x + slotflowposx) * slotflowsizex; cornerrighttex3y = (cornerrighttex3y + slotflowposy) * slotflowsizey
	
	if (topflow)
	{
		toptex0x = (toptex0x + slotflowposx) * slotflowsizex; toptex0y = (toptex0y + slotflowposy) * slotflowsizey
		toptex1x = (toptex1x + slotflowposx) * slotflowsizex; toptex1y = (toptex1y + slotflowposy) * slotflowsizey
		toptex2x = (toptex2x + slotflowposx) * slotflowsizex; toptex2y = (toptex2y + slotflowposy) * slotflowsizey
		toptex3x = (toptex3x + slotflowposx) * slotflowsizex; toptex3y = (toptex3y + slotflowposy) * slotflowsizey
		topmidtexx = (topmidtexx + slotflowposx) * slotflowsizex; topmidtexy = (topmidtexy + slotflowposy) * slotflowsizey
	}
	else
	{
		toptex0x = (toptex0x + slotstillposx) * slotstillsizex; toptex0y = (toptex0y + slotstillposy) * slotstillsizey
		toptex1x = (toptex1x + slotstillposx) * slotstillsizex; toptex1y = (toptex1y + slotstillposy) * slotstillsizey
		toptex2x = (toptex2x + slotstillposx) * slotstillsizex; toptex2y = (toptex2y + slotstillposy) * slotstillsizey
		toptex3x = (toptex3x + slotstillposx) * slotstillsizex; toptex3y = (toptex3y + slotstillposy) * slotstillsizey
		topmidtexx = (topmidtexx + slotstillposx) * slotstillsizex; topmidtexy = (topmidtexy + slotstillposy) * slotstillsizey
	}
	
	// Add triangles
	var x1, x2, y1, y2, z1, z2;
	var midx, midy, midz;
	
	x1 = block_pos_x;	  y1 = block_pos_y;		z1 = floor(block_pos_z);
	x2 = x1 + block_size; y2 = y1 + block_size; z2 = z1 + minz;
	
	midx = x1 + block_size / 2
	midy = y1 + block_size / 2
	midz = z1 + averagez
	
	// Move waterlogged sides in to prevent Z fighting a little
	if (waterlogged)
	{
		var indent = 0.05;
		
		// X+
		if (!matchxp)
			x2 -= indent
		
		// X-
		if (!matchxn)
			x1 += indent
		
		// Y+
		if (!matchyp)
			y2 -= indent
		
		// Y-
		if (!matchyn)
			y1 += indent
	}
	
	corner0z += z1
	corner1z += z1
	corner2z += z1
	corner3z += z1
	
	block_vbuffer_current = mc_builder.vbuffer[dep, vbuf]
	block_vertex_emissive = block_current.emissive
	
	// X+
	if (!matchxp && !solidxp)
	{
		builder_add_face(x2, y2, z2, x2, y1, z2, x2, y1, z1, x2, y2, z1, sidetex0x, sidetex0y, sidetex1x, sidetex1y, sidetex2x, sidetex2y, sidetex3x, sidetex3y, null)
		if (corner1z > corner2z)
			builder_add_triangle(x2, y1, z2, x2, y2, z2, x2, y1, corner1z, sidetex1x, sidetex1y, sidetex0x, sidetex0y, cornerrighttex1x, cornerrighttex1y, null)
		else
			builder_add_triangle(x2, y1, z2, x2, y2, z2, x2, y2, corner2z, sidetex1x, sidetex1y, sidetex0x, sidetex0y, cornerlefttex2x, cornerlefttex2y, null)
	}

	// X-
	if (!matchxn && !solidxn)
	{
		builder_add_face(x1, y1, z2, x1, y2, z2, x1, y2, z1, x1, y1, z1, sidetex0x, sidetex0y, sidetex1x, sidetex1y, sidetex2x, sidetex2y, sidetex3x, sidetex3y, null)
		if (corner3z > corner0z)
			builder_add_triangle(x1, y2, z2, x1, y1, z2, x1, y2, corner3z, sidetex1x, sidetex1y, sidetex0x, sidetex0y, cornerrighttex3x, cornerrighttex3y, null)
		else
			builder_add_triangle(x1, y2, z2, x1, y1, z2, x1, y1, corner0z, sidetex1x, sidetex1y, sidetex0x, sidetex0y, cornerlefttex0x, cornerlefttex0y, null)
	}

	// Y+
	if (!matchyp && !solidyp)
	{
		builder_add_face(x1, y2, z2, x2, y2, z2, x2, y2, z1, x1, y2, z1, sidetex0x, sidetex0y, sidetex1x, sidetex1y, sidetex2x, sidetex2y, sidetex3x, sidetex3y, null)
		if (corner2z > corner3z)
			builder_add_triangle(x2, y2, z2, x1, y2, z2, x2, y2, corner2z, sidetex1x, sidetex1y, sidetex0x, sidetex0y, cornerrighttex2x, cornerrighttex2y, null)
		else
			builder_add_triangle(x2, y2, z2, x1, y2, z2, x1, y2, corner3z, sidetex1x, sidetex1y, sidetex0x, sidetex0y, cornerlefttex3x, cornerlefttex3y, null)
	}

	// Y-
	if (!matchyn && !solidyn)
	{
		builder_add_face(x2, y1, z2, x1, y1, z2, x1, y1, z1, x2, y1, z1, sidetex0x, sidetex0y, sidetex1x, sidetex1y, sidetex2x, sidetex2y, sidetex3x, sidetex3y, null)
		if (corner0z > corner1z)
			builder_add_triangle(x1, y1, z2, x2, y1, z2, x1, y1, corner0z, sidetex1x, sidetex1y, sidetex0x, sidetex0y, cornerrighttex0x, cornerrighttex0y, null)
		else
			builder_add_triangle(x1, y1, z2, x2, y1, z2, x2, y1, corner1z, sidetex1x, sidetex1y, sidetex0x, sidetex0y, cornerlefttex1x, cornerlefttex1y, null)
	}

	// Z+
	if (!matchzp)
	{
		builder_add_triangle(midx, midy, midz, x1, y1, corner0z, x2, y1, corner1z, topmidtexx, topmidtexy, toptex0x, toptex0y, toptex1x, toptex1y, null)
		builder_add_triangle(midx, midy, midz, x2, y1, corner1z, x2, y2, corner2z, topmidtexx, topmidtexy, toptex1x, toptex1y, toptex2x, toptex2y, null)
		builder_add_triangle(midx, midy, midz, x2, y2, corner2z, x1, y2, corner3z, topmidtexx, topmidtexy, toptex2x, toptex2y, toptex3x, toptex3y, null)
		builder_add_triangle(midx, midy, midz, x1, y2, corner3z, x1, y1, corner0z, topmidtexx, topmidtexy, toptex3x, toptex3y, toptex0x, toptex0y, null)
	}

	// Z-
	if (!matchzn && !solidzn)
		builder_add_face(x1, y2, z1, x2, y2, z1, x2, y1, z1, x1, y1, z1, toptex3x, toptex3y, toptex2x, toptex2y, toptex1x, toptex1y, toptex0x, toptex0y, null)

	
	block_vertex_rgb = c_white
	block_vertex_alpha = 1
}
