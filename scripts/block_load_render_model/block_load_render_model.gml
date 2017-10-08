/// block_load_render_model(model, rotation, uvlock, opaque, weight)
/// @arg model
/// @arg rotation
/// @arg uvlock
/// @arg opaque
/// @arg weight
/// @desc Creates a render-ready model from the loaded files.

var model, rot, uvlock, wei, opaque, rotmat;
model = argument0
rot = argument1
uvlock = argument2
opaque = argument3
wei = argument4

// Create matrix for rotation
if (rot[X] > 0 || rot[Z] > 0)
{
	rotmat = matrix_create(point3D(-block_size / 2, -block_size / 2, -block_size / 2), vec3(0), vec3(1))
	rotmat = matrix_multiply(rotmat, matrix_create(point3D(block_size / 2, block_size / 2, block_size / 2), vec3(-rot[X], 0, -rot[Z]), vec3(1)))
}
else
	rotmat = MAT_IDENTITY

with (new(obj_block_render_model))
{
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
	
	// Reset brightness
	brightness = 0
	
	// Reset offset
	offset_x = 0
	offset_y = 0
	offset_z = 0
	
	// Set weight
	weight = wei
	
	// For culling
	for (var f = 0; f < e_dir.amount; f++)
	{
		face_full[f, Z] = false
		face_min[f, X] = null
		face_max[f, X] = null
		face_min[f, Y] = null
		face_max[f, Y] = null
		face_min[f, Z] = null
		face_max[f, Z] = null
		face_min_depth[f] = null
	}
	
	// Add elements
	element_amount = 0
	if (elementmodel != null)
	{
		for (var e = 0; e < elementmodel.element_amount; e++)
		{
			var elem = elementmodel.element[e];
			
			// Generate render element from loaded element
			with (new(obj_block_render_element))
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
					}
					
					// Auto generate UVs
					else
					{
						switch (f)
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
					}
					
					// Shift UVs anti-clockwise by face rotation
					var facerot = elem.face_rotation[f];
					if (!uvlock)
						facerot += mod_fix(faceuvrot[nd], 360)
						
					repeat (facerot / 90)
					{
						var tmp = face_uv[nd, 0];
						face_uv[nd, 0] = face_uv[nd, 3]
						face_uv[nd, 3] = face_uv[nd, 2]
						face_uv[nd, 2] = face_uv[nd, 1]
						face_uv[nd, 1] = tmp
					}
					
					// Texture
					var texname;
					if (uvlock && elem.face_render[nd]) // Keep texture on UV lock
						texname = elem.face_texture[nd]
					else
						texname = elem.face_texture[f]
					
					while (string_char_at(texname, 1) = "#") // Fetch from map
						texname = texturemap[?string_delete(texname, 1, 1)]
						
					// Texture color
					face_texture_color[nd] = -1
					
					// Apply UVs to block sheet
					var slot, slotpos, texsize, sheetwidth, sheetheight;
					slot = -1
					
					if (opaque)
						slot = ds_list_find_index(mc_assets.block_texture_list, texname + " opaque")
					if (slot < 0)
						slot = ds_list_find_index(mc_assets.block_texture_list, texname)
					
					if (slot < 0) // Not in static sheet, is it animated?
					{
						if (opaque)
							slot = ds_list_find_index(mc_assets.block_texture_ani_list, texname + " opaque")
						if (slot < 0)
							slot = ds_list_find_index(mc_assets.block_texture_ani_list, texname)
						
						if (slot < 0) // Missing texture, skip face
						{
							face_render[nd] = false
							continue
						}
						
						face_depth[nd] = mc_res.block_sheet_ani_depth_list[|slot]
						face_vbuffer[nd] = e_block_vbuffer.ANIMATED
						sheetwidth = block_sheet_ani_width
						sheetheight = block_sheet_ani_height
					}
					else
					{
						face_depth[nd] = mc_res.block_sheet_depth_list[|slot]
						face_vbuffer[nd] = e_block_vbuffer.NORMAL
						sheetwidth = block_sheet_width
						sheetheight = block_sheet_height
						
						// Check color
						var col = mc_assets.block_texture_color_map[?texname];
						if (!is_undefined(col))
						{
							if (is_real(col))
								face_texture_color[nd] = col
							else if (col = "grass")
								face_vbuffer[nd] = e_block_vbuffer.GRASS
							else if (col = "leaves")
								face_vbuffer[nd] = e_block_vbuffer.LEAVES
						}
					}
					
					slotpos = point2D((slot mod sheetwidth) * block_size, (slot div sheetwidth) *  block_size)
					texsize = vec2(1 / (sheetwidth * block_size), 1 / (sheetheight * block_size))
					
					// Apply to UV
					for (var t = 0; t < 4; t++)
						face_uv[nd, t] = vec2_mul(point2D_add(face_uv[nd, t], slotpos), texsize)
						
					// For culling
					face_edge[nd] = false
					if (!rotated)
					{
						// Check with edge
						switch (nd)
						{
							case e_dir.EAST:	face_edge[nd] = (to[X] = block_size);	break
							case e_dir.WEST:	face_edge[nd] = (from[X] = 0);			break
							case e_dir.SOUTH:	face_edge[nd] = (to[Y] = block_size);	break
							case e_dir.NORTH:	face_edge[nd] = (from[Y] = 0);			break
							case e_dir.UP:		face_edge[nd] = (to[Z] = block_size);	break
							case e_dir.DOWN:	face_edge[nd] = (from[Z] = 0);			break
						}
						
						if (face_edge[nd])
						{
							// Check with each direction
							var dirvec = dir_get_vec3(nd);
							for (var a = X; a <= Z; a++)
							{
								if (dirvec[a] != 0)
									continue
								
								// Set min and max for this axis
								if (!other.face_full[nd, a])
								{
									if ((other.face_min[nd, a] = null || from[a] <= other.face_min[nd, a]) && 
										(other.face_max[nd, a] = null || to[a] >= other.face_max[nd, a]))
									{
										other.face_min[nd, a] = from[a]
										other.face_max[nd, a] = to[a]
								
										if (other.face_min[nd, a] = 0 && other.face_max[nd, a] = block_size)
											other.face_full[nd, a] = true
									}
								}
							}
							
							if (other.face_min_depth[nd] = null || face_depth[nd] < other.face_min_depth[nd])
								other.face_min_depth[nd] = face_depth[nd]
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
	
	face_full_xp = (face_full[e_dir.EAST, Y] && face_full[e_dir.EAST, Z])
	face_min_y_xp = face_min[e_dir.EAST, Y]
	face_max_y_xp = face_max[e_dir.EAST, Y]
	face_min_z_xp = face_min[e_dir.EAST, Z]
	face_max_z_xp = face_max[e_dir.EAST, Z]
	face_min_depth_xp = face_min_depth[e_dir.EAST]
	
	face_full_xn = (face_full[e_dir.WEST, Y] && face_full[e_dir.WEST, Z])
	face_min_y_xn = face_min[e_dir.WEST, Y]
	face_max_y_xn = face_max[e_dir.WEST, Y]
	face_min_z_xn = face_min[e_dir.WEST, Z]
	face_max_z_xn = face_max[e_dir.WEST, Z]
	face_min_depth_xn = face_min_depth[e_dir.WEST]
	
	face_full_yp = (face_full[e_dir.SOUTH, X] && face_full[e_dir.SOUTH, Z])
	face_min_x_yp = face_min[e_dir.SOUTH, X]
	face_max_x_yp = face_max[e_dir.SOUTH, X]
	face_min_z_yp = face_min[e_dir.SOUTH, Z]
	face_max_z_yp = face_max[e_dir.SOUTH, Z]
	face_min_depth_yp = face_min_depth[e_dir.SOUTH]
	
	face_full_yn = (face_full[e_dir.NORTH, X] && face_full[e_dir.NORTH, Z])
	face_min_x_yn = face_min[e_dir.NORTH, X]
	face_max_x_yn = face_max[e_dir.NORTH, X]
	face_min_z_yn = face_min[e_dir.NORTH, Z]
	face_max_z_yn = face_max[e_dir.NORTH, Z]
	face_min_depth_yn = face_min_depth[e_dir.NORTH]
	
	face_full_zp = (face_full[e_dir.UP, X] && face_full[e_dir.UP, Y])
	face_min_x_zp = face_min[e_dir.UP, X]
	face_max_x_zp = face_max[e_dir.UP, X]
	face_min_y_zp = face_min[e_dir.UP, Y]
	face_max_y_zp = face_max[e_dir.UP, Y]
	face_min_depth_zp = face_min_depth[e_dir.UP]
	
	face_full_zn = (face_full[e_dir.DOWN, X] && face_full[e_dir.DOWN, Y])
	face_min_x_zn = face_min[e_dir.DOWN, X]
	face_max_x_zn = face_max[e_dir.DOWN, X]
	face_min_y_zn = face_min[e_dir.DOWN, Y]
	face_max_y_zn = face_max[e_dir.DOWN, Y]
	face_min_depth_zn = face_min_depth[e_dir.DOWN]
	
	ds_map_destroy(texturemap)
	return id
}