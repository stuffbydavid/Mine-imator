/// block_load_render_model(model, rotation, uvlock, opaque, weight, [resource])
/// @arg model
/// @arg rotation
/// @arg uvlock
/// @arg opaque
/// @arg weight
/// @arg [resource]
/// @desc Creates a render-ready model from the loaded files.

function block_load_render_model(model, rot, uvlock, opaque, wei, res = null)
{
	var rotmat, modelstate, colY, alphaY, colZ, alphaZ
	
	// Get 
	if (res = null)
	{
		modelstate = model_state_obj.id
		colY = modelstate.model_preview_color_yp
		alphaY = modelstate.model_preview_alpha_yp
		colZ = modelstate.model_preview_color_zp
		alphaZ = modelstate.model_preview_alpha_zp
	}
	else
	{
		modelstate = null
		colY = null
		alphaY = null
		colZ = null
		alphaZ = null
	}
	
	// Create matrix for rotation
	if (rot[X] > 0 || rot[Z] > 0)
	{
		rotmat = matrix_create(point3D(-block_size / 2, -block_size / 2, -block_size / 2), vec3(0), vec3(1))
		rotmat = matrix_multiply(rotmat, matrix_create(point3D(block_size / 2, block_size / 2, block_size / 2), vec3(-rot[X], 0, -rot[Z]), vec3(1)))
	}
	else
		rotmat = MAT_IDENTITY
	
	with (new_obj(obj_block_render_model))
	{
		rendermodel_id = array_length(block_rendermodels)
		array_add(block_rendermodels, id)
		
		var elementmodel, texturemap;
		elementmodel = null
		texturemap = ds_map_create()
		
		// Go through parents
		while (model != null)
		{
			// Add textures
			if (model.texture_map != null)
				ds_map_merge(texturemap, model.texture_map, false)
			
			// Choose the first model that contains elements
			if (elementmodel = null && model.element_amount > 0)
				elementmodel = model
			
			model = model.parent
		}
		
		// Reset emissive
		emissive = 0
		
		// Reset random offset
		random_offset = 0
		random_offset_xy = 0
		
		// Reset offset
		offset_x = 0
		offset_y = 0
		offset_z = 0
		
		// Set weight
		weight = wei
		
		// For culling
		for (var f = 0; f < e_dir.amount; f++)
		{
			face_full[f] = false
			face_min[f] = null
			face_max[f] = null
			face_min_depth[f] = null
		}
		
		// For the world importer
		preview_color_zp = null
		preview_alpha_zp = 0
		preview_color_yp = null
		preview_alpha_yp = 0
		preview_tint = ""
		
		// Add elements
		element_amount = 0
		if (elementmodel != null)
		{
			for (var e = 0; e < elementmodel.element_amount; e++)
			{
				var elem = elementmodel.element[e];
				
				// Generate render element from loaded element
				with (new_obj(obj_block_render_element))
				{
					from = elem.from
					to = elem.to
					
					// Set face rotations and rotated directions
					var facenewdir, faceuvrot;
					for (var f = 0; f < e_dir.amount; f++)
					{
						facenewdir[f] = f
						faceuvrot[f] = 0
					}
					
					rotated = elem.rotated
					if (rotated)
						matrix = matrix_multiply(elem.matrix, rotmat)
					else if (rot[X] > 0 || rot[Z] > 0)
					{
						// Rotate points
						from = point3D_mul_matrix(elem.from, rotmat)
						to = point3D_mul_matrix(elem.to, rotmat)
						
						for (var a = X; a <= Z; a++)
						{
							var mi = min(from[a], to[a]);
							var ma = max(from[a], to[a]);
							from[a] = snap(mi, 0.01)
							to[a] = snap(ma, 0.01)
						}
						
						// Shift face references (clockwise, Z -> X)
						repeat (rot[Z] / 90)
						{
							var eastrotdir = facenewdir[e_dir.EAST];
							facenewdir[e_dir.EAST] = facenewdir[e_dir.SOUTH]
							facenewdir[e_dir.SOUTH] = facenewdir[e_dir.WEST]
							facenewdir[e_dir.WEST] = facenewdir[e_dir.NORTH]
							facenewdir[e_dir.NORTH] = eastrotdir
						}
						
						repeat (rot[X] / 90)
						{
							var uprotdir = facenewdir[e_dir.UP];
							facenewdir[e_dir.UP] = facenewdir[e_dir.NORTH]
							facenewdir[e_dir.NORTH] = facenewdir[e_dir.DOWN]
							facenewdir[e_dir.DOWN] = facenewdir[e_dir.SOUTH]
							facenewdir[e_dir.SOUTH] = uprotdir
						}
						
						// Rotate UV by shape rotation
						switch (rot[X])
						{
							case 0:
							{
								faceuvrot[e_dir.UP] = rot[Z]
								faceuvrot[e_dir.DOWN] = -rot[Z]
								break
							}
							
							case 90:
							{
								faceuvrot[facenewdir[e_dir.EAST]] = 90
								faceuvrot[facenewdir[e_dir.WEST]] = -90
								faceuvrot[facenewdir[e_dir.UP]] = 180
								faceuvrot[e_dir.UP] = rot[Z]
								faceuvrot[e_dir.DOWN] = 180 - rot[Z]
								break
							}
							
							case 180:
							{
								faceuvrot[e_dir.EAST] = 180
								faceuvrot[e_dir.WEST] = 180
								faceuvrot[e_dir.SOUTH] = 180
								faceuvrot[e_dir.NORTH] = 180
								faceuvrot[e_dir.UP] = rot[Z]
								faceuvrot[e_dir.DOWN] = -rot[Z]
								break
							}
							
							case 270:
							{
								faceuvrot[facenewdir[e_dir.EAST]] = -90
								faceuvrot[facenewdir[e_dir.WEST]] = 90
								faceuvrot[facenewdir[e_dir.DOWN]] = 180
								faceuvrot[e_dir.UP] = 180 + rot[Z]
								faceuvrot[e_dir.DOWN] = -rot[Z]
								break
							}
						}
					}
					
					for (var f = 0; f < e_dir.amount; f++)
					{
						var nd = facenewdir[f];
						
						face_render[nd] = elem.face_render[f]
						if (!face_render[nd])
							continue
						
						var facerot = elem.face_rotation[f];
						if (!uvlock)
							facerot += mod_fix(faceuvrot[nd], 360)
						
						// UV
						if (elem.face_has_uv[f])
						{
							var uvfrom, uvto;
							
							if (uvlock && faceuvrot[nd] != 0)
							{
								// Rotate points by opposite angle
								uvfrom = uv_rotate(elem.face_uv_from[f], -faceuvrot[nd], point2D(block_size / 2, block_size / 2))
								uvto = uv_rotate(elem.face_uv_to[f], -faceuvrot[nd], point2D(block_size / 2, block_size / 2))
								
								for (var a = X; a <= Y; a++)
								{
									var mi = min(uvfrom[a], uvto[a]);
									var ma = max(uvfrom[a], uvto[a]);
									uvfrom[a] = snap(mi, 0.01)
									uvto[a] = snap(ma, 0.01)
								}
							}
							else
							{
								uvfrom = elem.face_uv_from[f]
								uvto = elem.face_uv_to[f]
							}
							
							face_uv[nd, 0] = uvfrom
							face_uv[nd, 1] = point2D(uvto[X], uvfrom[Y])
							face_uv[nd, 2] = uvto
							face_uv[nd, 3] = point2D(uvfrom[X], uvto[Y])
							
							// Shift UVs anti-clockwise by face rotation
							repeat (facerot / 90)
							{
								var tmp = face_uv[nd, 0];
								face_uv[nd, 0] = face_uv[nd, 3]
								face_uv[nd, 3] = face_uv[nd, 2]
								face_uv[nd, 2] = face_uv[nd, 1]
								face_uv[nd, 1] = tmp
							}
						}
						
						// Auto generate UVs
						else
						{
							switch (nd)
							{
								case e_dir.EAST:
									face_uv[nd, 0] = point2D(block_size - to[Y], block_size - to[Z])
									face_uv[nd, 1] = point2D(block_size - from[Y], block_size - to[Z])
									face_uv[nd, 2] = point2D(block_size - from[Y], block_size - from[Z])
									face_uv[nd, 3] = point2D(block_size - to[Y], block_size - from[Z])
									break
								
								case e_dir.WEST:
									face_uv[nd, 0] = point2D(from[Y], block_size - to[Z])
									face_uv[nd, 1] = point2D(to[Y], block_size - to[Z])
									face_uv[nd, 2] = point2D(to[Y], block_size - from[Z])
									face_uv[nd, 3] = point2D(from[Y], block_size - from[Z])
									break
								
								case e_dir.SOUTH:
									face_uv[nd, 0] = point2D(from[X], block_size - to[Z])
									face_uv[nd, 1] = point2D(to[X], block_size - to[Z])
									face_uv[nd, 2] = point2D(to[X], block_size - from[Z])
									face_uv[nd, 3] = point2D(from[X], block_size - from[Z])
									break
								
								case e_dir.NORTH:
									face_uv[nd, 0] = point2D(block_size - to[X], block_size - to[Z])
									face_uv[nd, 1] = point2D(block_size - from[X], block_size - to[Z])
									face_uv[nd, 2] = point2D(block_size - from[X], block_size - from[Z])
									face_uv[nd, 3] = point2D(block_size - to[X], block_size - from[Z])
									break
								
								case e_dir.UP:
									face_uv[nd, 0] = point2D(from[X], from[Y])
									face_uv[nd, 1] = point2D(to[X], from[Y])
									face_uv[nd, 2] = point2D(to[X], to[Y])
									face_uv[nd, 3] = point2D(from[X], to[Y])
									break
								
								case e_dir.DOWN:
									face_uv[nd, 0] = point2D(from[X], block_size - to[Y])
									face_uv[nd, 1] = point2D(to[X], block_size - to[Y])
									face_uv[nd, 2] = point2D(to[X], block_size - from[Y])
									face_uv[nd, 3] = point2D(from[X], block_size - from[Y])
									break
							}
							
							// Shift UVs anti-clockwise by face rotation
							if (facerot > 0)
							{
								face_uv[nd, 0] = uv_rotate(face_uv[nd, 0], facerot, point2D(block_size / 2, block_size / 2))
								face_uv[nd, 1] = uv_rotate(face_uv[nd, 1], facerot, point2D(block_size / 2, block_size / 2))
								face_uv[nd, 2] = uv_rotate(face_uv[nd, 2], facerot, point2D(block_size / 2, block_size / 2))
								face_uv[nd, 3] = uv_rotate(face_uv[nd, 3], facerot, point2D(block_size / 2, block_size / 2))
							}
						}
						
						// Artifact fix with CPU rendering
						for (var i = 0; i < 4; i++)
						{
							var fuv = face_uv[nd, i];
							fuv[X] = min(block_size - 1 / 256, fuv[X])
							fuv[Y] = min(block_size - 1 / 256, fuv[Y])
							face_uv[nd, i] = fuv
						}
						
						// Texture
						var texname, texpos, texsize;
						if (uvlock && elem.face_render[nd]) // Keep texture on UV lock
							texname = elem.face_texture[nd]
						else
							texname = elem.face_texture[f]
						
						while (string_char_at(texname, 1) = "#") // Fetch from map
						{
							texname = string_delete(texname, 1, 1)
							if (is_undefined(texturemap[?texname]))
							{
								log("Could not find block texture", texname)
								texname = ""
								break
							}
							texname = texturemap[?texname]
						}
						
						// Texture variable is not defined, skip face
						if (texname = "")
						{
							face_render[nd] = false
							continue
						}
						
						// Texture color
						face_texture_color[nd] = -1
						
						// Check texture with resource
						if (res != null && res.model_texture_map != null && !is_undefined(res.model_texture_map[?texname]))
						{
							face_depth[nd] = e_block_depth.DEPTH2
							face_block_vbuffer[nd] = null
							face_vbuffer[nd] = res.model_block_map[?texname]
							if (is_undefined(face_vbuffer[nd]))
							{
								face_vbuffer[nd] = vbuffer_start()
								res.model_block_map[?texname] = face_vbuffer[nd]
							}
							
							texpos = vec2(0, 0)
							texsize = vec2(block_size, block_size)
						}
						else
						{
							// Apply UVs to block sheet/texture
							var slot, sheetwidth, sheetheight;
							slot = -1
							
							face_vbuffer[nd] = null
							
							if (opaque)
								slot = ds_list_find_index(mc_assets.block_texture_list, texname + " opaque")
							if (slot < 0)
								slot = ds_list_find_index(mc_assets.block_texture_list, texname + " noalpha")
							if (slot < 0)
								slot = ds_list_find_index(mc_assets.block_texture_list, texname)
							
							if (slot < 0) // Not in static sheet, is it animated?
							{
								if (slot < 0)
									slot = ds_list_find_index(mc_assets.block_texture_ani_list, texname)
								
								// Check for tags
								if (slot < 0)
									slot = ds_list_find_index(mc_assets.block_texture_list, texname + " noalpha")
								
								if (slot < 0)
									slot = ds_list_find_index(mc_assets.block_texture_ani_list, texname + " opaque")
								
								if (slot < 0) // Missing texture, skip face
								{
									face_render[nd] = false
									continue
								}
								
								face_depth[nd] = mc_res.block_sheet_ani_depth_list[|slot]
								face_block_vbuffer[nd] = e_block_vbuffer.ANIMATED
								
								// Check color
								var col = mc_assets.block_texture_color_map[?texname];
								if (!is_undefined(col) && col = "water")
									face_block_vbuffer[nd] = e_block_vbuffer.WATER
								
								sheetwidth = block_sheet_ani_width
								sheetheight = block_sheet_ani_height
							}
							else
							{
								face_depth[nd] = mc_res.block_sheet_depth_list[|slot]
								face_block_vbuffer[nd] = e_block_vbuffer.NORMAL
								sheetwidth = block_sheet_width
								sheetheight = block_sheet_height
								
								// Check color
								var col = mc_assets.block_texture_color_map[?texname];
								if (!is_undefined(col))
								{
									if (is_real(col))
										face_texture_color[nd] = col
									else
									{
										switch (col)
										{
											case "grass":			face_block_vbuffer[nd] = e_block_vbuffer.GRASS;				break;
											case "foliage":			face_block_vbuffer[nd] = e_block_vbuffer.FOLIAGE;			break;
											
											case "oak_leaves":		face_block_vbuffer[nd] = e_block_vbuffer.LEAVES_OAK;		break;
											case "spruce_leaves":	face_block_vbuffer[nd] = e_block_vbuffer.LEAVES_SPRUCE;		break;
											case "birch_leaves":	face_block_vbuffer[nd] = e_block_vbuffer.LEAVES_BIRCH;		break;
											case "jungle_leaves":	face_block_vbuffer[nd] = e_block_vbuffer.LEAVES_JUNGLE;		break;
											case "acacia_leaves":	face_block_vbuffer[nd] = e_block_vbuffer.LEAVES_ACACIA;		break;
											case "dark_oak_leaves":	face_block_vbuffer[nd] = e_block_vbuffer.LEAVES_DARK_OAK;	break;
											case "mangrove_leaves":	face_block_vbuffer[nd] = e_block_vbuffer.LEAVES_MANGROVE;	break;
										}	
									}
								}
							}
							
							texpos = point2D((slot mod sheetwidth) * block_size, (slot div sheetwidth) * block_size)
							texsize = vec2(sheetwidth * block_size, sheetheight * block_size)
							
							// Get preview color for world importer
							if (res = null)
							{
								if ((nd = e_dir.UP && other.preview_color_zp = null && alphaZ != 0) ||
									(nd = e_dir.SOUTH && other.preview_color_yp = null && alphaY != 0))
								{
									if (face_block_vbuffer[nd] = e_block_vbuffer.ANIMATED || face_block_vbuffer[nd] = e_block_vbuffer.WATER)
										buffer_current = load_assets_block_preview_ani_buffer
									else
										buffer_current = load_assets_block_preview_buffer
									
									var px, py, alpha, col;
									px = slot mod sheetwidth
									py = slot div sheetwidth
									
									if ((nd = e_dir.UP && alphaZ = -1) || (nd = e_dir.SOUTH && alphaY = -1))
										alpha = buffer_read_alpha(px, py, sheetwidth)
									else
										alpha = (nd = e_dir.UP ? alphaZ : alphaY)
									
									// Not transparent
									if (alpha > 0)
									{
										if ((nd = e_dir.UP && colZ = -1) || (nd = e_dir.SOUTH && colY = -1))
											col = buffer_read_color(px, py, sheetwidth)
										else
											col = (nd = e_dir.UP ? colZ : colY)
										
										if (face_texture_color[nd] > -1)
											col = color_multiply(col, face_texture_color[nd])
										else
										{
											var rescol, colstr;
											rescol = null
											colstr = ""
											switch (face_block_vbuffer[nd])
											{
												case e_block_vbuffer.GRASS:				colstr = "grass";						break;
												case e_block_vbuffer.FOLIAGE:			colstr = "foliage";						break;
												case e_block_vbuffer.WATER:				colstr = "water";						break;
												case e_block_vbuffer.LEAVES_OAK:		colstr = "foliage";						break;
												case e_block_vbuffer.LEAVES_SPRUCE:		rescol = mc_res.color_leaves_spruce;	break;
												case e_block_vbuffer.LEAVES_BIRCH:		rescol = mc_res.color_leaves_birch;		break;
												case e_block_vbuffer.LEAVES_JUNGLE:		colstr = "foliage";						break;
												case e_block_vbuffer.LEAVES_ACACIA:		colstr = "foliage";						break;
												case e_block_vbuffer.LEAVES_DARK_OAK:	colstr = "foliage";						break;
												case e_block_vbuffer.LEAVES_MANGROVE:	colstr = "foliage";						break;
											}
											
											if (rescol != null)
												col = color_multiply(rescol, col)
											
											other.preview_tint = colstr;
										}
										
										if (nd = e_dir.UP)
										{
											other.preview_color_zp = col
											other.preview_alpha_zp = alpha
										}
										else
										{
											other.preview_color_yp = col
											other.preview_alpha_yp = alpha
										}
									}
								}
							}
						}
						
						// Apply to UV
						for (var t = 0; t < 4; t++)
							face_uv[nd, t] = vec2_div(point2D_add(face_uv[nd, t], texpos), texsize)
						
						// For culling
						face_edge[nd] = false
						if (!rotated)
						{
							switch (nd)
							{
								case e_dir.EAST:
								case e_dir.WEST:
								{
									if (nd = e_dir.EAST)
										face_edge[nd] = (to[X] = block_size)
									else
										face_edge[nd] = (from[X] = 0)
									
									if (face_edge[nd] && !other.face_full[nd])
									{
										if (from[Y] = 0 && to[Y] = block_size)
										{
											if (other.face_min[nd] = null || from[Z] <= other.face_min[nd])
												other.face_min[nd] = from[Z]
											
											if (other.face_max[nd] = null || to[Z] >= other.face_max[nd])
												other.face_max[nd] = to[Z]
											
											if (other.face_min[nd] = 0 && other.face_max[nd] = block_size)
												other.face_full[nd] = true
										}
										
										if (other.face_min_depth[nd] = null || face_depth[nd] < other.face_min_depth[nd])
											other.face_min_depth[nd] = face_depth[nd]
									}
									
									break
								}
								
								case e_dir.SOUTH:
								case e_dir.NORTH:
								{
									if (nd = e_dir.SOUTH)
										face_edge[nd] = (to[Y] = block_size)
									else
										face_edge[nd] = (from[Y] = 0)
									
									if (face_edge[nd] && !other.face_full[nd])
									{
										if (from[X] = 0 && to[X] = block_size)
										{
											if (other.face_min[nd] = null || from[Z] <= other.face_min[nd])
												other.face_min[nd] = from[Z]
											
											if (other.face_max[nd] = null || to[Z] >= other.face_max[nd])
												other.face_max[nd] = to[Z]
											
											if (other.face_min[nd] = 0 && other.face_max[nd] = block_size)
												other.face_full[nd] = true
										}
										
										if (other.face_min_depth[nd] = null || face_depth[nd] < other.face_min_depth[nd])
											other.face_min_depth[nd] = face_depth[nd]
									}
									
									break
								}
								
								case e_dir.UP:
								case e_dir.DOWN:
								{
									if (nd = e_dir.UP)
										face_edge[nd] = (to[Z] = block_size)
									else
										face_edge[nd] = (from[Z] = 0)
									
									if (face_edge[nd] && !other.face_full[nd])
									{
										if (from[X] = 0 && to[X] = block_size)
										{
											if (other.face_min[nd] = null || from[Y] <= other.face_min[nd])
												other.face_min[nd] = from[Y]
											
											if (other.face_max[nd] = null || to[Y] >= other.face_max[nd])
												other.face_max[nd] = to[Y]
											
											if (other.face_min[nd] = 0 && other.face_max[nd] = block_size)
												other.face_full[nd] = true
										}
										
										if (other.face_min_depth[nd] = null || face_depth[nd] < other.face_min_depth[nd])
											other.face_min_depth[nd] = face_depth[nd]
									}
									
									break
								}
							}
						}
					}
					
					// Convert from arrays
					
					from_x = from[X]
					from_y = from[Y]
					from_z = from[Z]
					
					to_x = to[X]
					to_y = to[Y]
					to_z = to[Z]
					
					face_render_xp = face_render[e_dir.EAST]
					face_render_xn = face_render[e_dir.WEST]
					face_render_yp = face_render[e_dir.SOUTH]
					face_render_yn = face_render[e_dir.NORTH]
					face_render_zp = face_render[e_dir.UP]
					face_render_zn = face_render[e_dir.DOWN]
					
					if (face_render_xp)
					{
						face_texture_color_xp = face_texture_color[e_dir.EAST]
						face_depth_xp = face_depth[e_dir.EAST]
						face_block_vbuffer_xp = face_block_vbuffer[e_dir.EAST]
						face_vbuffer_xp = face_vbuffer[e_dir.EAST]
						face_edge_xp = face_edge[e_dir.EAST]
						face_uv_xp_0 = face_uv[e_dir.EAST, 0];	face_uv_xp_0_x = face_uv_xp_0[X];	 face_uv_xp_0_y = face_uv_xp_0[Y];
						face_uv_xp_1 = face_uv[e_dir.EAST, 1];	face_uv_xp_1_x = face_uv_xp_1[X];	 face_uv_xp_1_y = face_uv_xp_1[Y];
						face_uv_xp_2 = face_uv[e_dir.EAST, 2];	face_uv_xp_2_x = face_uv_xp_2[X];	 face_uv_xp_2_y = face_uv_xp_2[Y];
						face_uv_xp_3 = face_uv[e_dir.EAST, 3];	face_uv_xp_3_x = face_uv_xp_3[X];	 face_uv_xp_3_y = face_uv_xp_3[Y];
					}
					
					if (face_render_xn)
					{
						face_texture_color_xn = face_texture_color[e_dir.WEST]
						face_depth_xn = face_depth[e_dir.WEST]
						face_block_vbuffer_xn = face_block_vbuffer[e_dir.WEST]
						face_vbuffer_xn = face_vbuffer[e_dir.WEST]
						face_edge_xn = face_edge[e_dir.WEST]
						face_uv_xn_0 = face_uv[e_dir.WEST, 0];	face_uv_xn_0_x = face_uv_xn_0[X];	 face_uv_xn_0_y = face_uv_xn_0[Y];
						face_uv_xn_1 = face_uv[e_dir.WEST, 1];	face_uv_xn_1_x = face_uv_xn_1[X];	 face_uv_xn_1_y = face_uv_xn_1[Y];
						face_uv_xn_2 = face_uv[e_dir.WEST, 2];	face_uv_xn_2_x = face_uv_xn_2[X];	 face_uv_xn_2_y = face_uv_xn_2[Y];
						face_uv_xn_3 = face_uv[e_dir.WEST, 3];	face_uv_xn_3_x = face_uv_xn_3[X];	 face_uv_xn_3_y = face_uv_xn_3[Y];
					}
					
					if (face_render_yp)
					{
						face_texture_color_yp = face_texture_color[e_dir.SOUTH]
						face_depth_yp = face_depth[e_dir.SOUTH]
						face_block_vbuffer_yp = face_block_vbuffer[e_dir.SOUTH]
						face_vbuffer_yp = face_vbuffer[e_dir.SOUTH]
						face_edge_yp = face_edge[e_dir.SOUTH]
						face_uv_yp_0 = face_uv[e_dir.SOUTH, 0];	face_uv_yp_0_x = face_uv_yp_0[X];	 face_uv_yp_0_y = face_uv_yp_0[Y];
						face_uv_yp_1 = face_uv[e_dir.SOUTH, 1];	face_uv_yp_1_x = face_uv_yp_1[X];	 face_uv_yp_1_y = face_uv_yp_1[Y];
						face_uv_yp_2 = face_uv[e_dir.SOUTH, 2];	face_uv_yp_2_x = face_uv_yp_2[X];	 face_uv_yp_2_y = face_uv_yp_2[Y];
						face_uv_yp_3 = face_uv[e_dir.SOUTH, 3];	face_uv_yp_3_x = face_uv_yp_3[X];	 face_uv_yp_3_y = face_uv_yp_3[Y];
					}
					
					if (face_render_yn)
					{
						face_texture_color_yn = face_texture_color[e_dir.NORTH]
						face_depth_yn = face_depth[e_dir.NORTH]
						face_block_vbuffer_yn = face_block_vbuffer[e_dir.NORTH]
						face_vbuffer_yn = face_vbuffer[e_dir.NORTH]
						face_edge_yn = face_edge[e_dir.NORTH]
						face_uv_yn_0 = face_uv[e_dir.NORTH, 0];	face_uv_yn_0_x = face_uv_yn_0[X];	 face_uv_yn_0_y = face_uv_yn_0[Y];
						face_uv_yn_1 = face_uv[e_dir.NORTH, 1];	face_uv_yn_1_x = face_uv_yn_1[X];	 face_uv_yn_1_y = face_uv_yn_1[Y];
						face_uv_yn_2 = face_uv[e_dir.NORTH, 2];	face_uv_yn_2_x = face_uv_yn_2[X];	 face_uv_yn_2_y = face_uv_yn_2[Y];
						face_uv_yn_3 = face_uv[e_dir.NORTH, 3];	face_uv_yn_3_x = face_uv_yn_3[X];	 face_uv_yn_3_y = face_uv_yn_3[Y];
					}
					
					if (face_render_zp)
					{
						face_texture_color_zp = face_texture_color[e_dir.UP]
						face_depth_zp = face_depth[e_dir.UP]
						face_block_vbuffer_zp = face_block_vbuffer[e_dir.UP]
						face_vbuffer_zp = face_vbuffer[e_dir.UP]
						face_edge_zp = face_edge[e_dir.UP]
						face_uv_zp_0 = face_uv[e_dir.UP, 0];	face_uv_zp_0_x = face_uv_zp_0[X];	 face_uv_zp_0_y = face_uv_zp_0[Y];
						face_uv_zp_1 = face_uv[e_dir.UP, 1];	face_uv_zp_1_x = face_uv_zp_1[X];	 face_uv_zp_1_y = face_uv_zp_1[Y];
						face_uv_zp_2 = face_uv[e_dir.UP, 2];	face_uv_zp_2_x = face_uv_zp_2[X];	 face_uv_zp_2_y = face_uv_zp_2[Y];
						face_uv_zp_3 = face_uv[e_dir.UP, 3];	face_uv_zp_3_x = face_uv_zp_3[X];	 face_uv_zp_3_y = face_uv_zp_3[Y];
					}
					
					if (face_render_zn)
					{
						face_texture_color_zn = face_texture_color[e_dir.DOWN]
						face_depth_zn = face_depth[e_dir.DOWN]
						face_block_vbuffer_zn = face_block_vbuffer[e_dir.DOWN]
						face_vbuffer_zn = face_vbuffer[e_dir.DOWN]
						face_edge_zn = face_edge[e_dir.DOWN]
						face_uv_zn_0 = face_uv[e_dir.DOWN, 0];	face_uv_zn_0_x = face_uv_zn_0[X];	 face_uv_zn_0_y = face_uv_zn_0[Y];
						face_uv_zn_1 = face_uv[e_dir.DOWN, 1];	face_uv_zn_1_x = face_uv_zn_1[X];	 face_uv_zn_1_y = face_uv_zn_1[Y];
						face_uv_zn_2 = face_uv[e_dir.DOWN, 2];	face_uv_zn_2_x = face_uv_zn_2[X];	 face_uv_zn_2_y = face_uv_zn_2[Y];
						face_uv_zn_3 = face_uv[e_dir.DOWN, 3];	face_uv_zn_3_x = face_uv_zn_3[X];	 face_uv_zn_3_y = face_uv_zn_3[Y];
					}
					
					other.element[other.element_amount++] = id
				}
			}
		}
		
		// Convert from arrays
		
		face_full_xp = face_full[e_dir.EAST]
		face_min_xp = face_min[e_dir.EAST]
		face_max_xp = face_max[e_dir.EAST]
		face_min_depth_xp = face_min_depth[e_dir.EAST]
		
		face_full_xn = face_full[e_dir.WEST]
		face_min_xn = face_min[e_dir.WEST]
		face_max_xn = face_max[e_dir.WEST]
		face_min_depth_xn = face_min_depth[e_dir.WEST]
		
		face_full_yp = face_full[e_dir.SOUTH]
		face_min_yp = face_min[e_dir.SOUTH]
		face_max_yp = face_max[e_dir.SOUTH]
		face_min_depth_yp = face_min_depth[e_dir.SOUTH]
		
		face_full_yn = face_full[e_dir.NORTH]
		face_min_yn = face_min[e_dir.NORTH]
		face_max_yn = face_max[e_dir.NORTH]
		face_min_depth_yn = face_min_depth[e_dir.NORTH]
		
		face_full_zp = face_full[e_dir.UP]
		face_min_zp = face_min[e_dir.UP]
		face_max_zp = face_max[e_dir.UP]
		face_min_depth_zp = face_min_depth[e_dir.UP]
		
		face_full_zn = face_full[e_dir.DOWN]
		face_min_zn = face_min[e_dir.DOWN]
		face_max_zn = face_max[e_dir.DOWN]
		face_min_depth_zn = face_min_depth[e_dir.DOWN]
		
		ds_map_destroy(texturemap)
		return id
	}
}
