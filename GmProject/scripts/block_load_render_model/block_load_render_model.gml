/// @desc Creates a render-ready model from the loaded files.
/// @arg model
/// @arg rotation
/// @arg uvlock
/// @arg opaque
/// @arg weight
/// @arg [resource]

function block_load_render_model(model, rot, uvlock, opaque, wei, res = null)
{
	var rotmat, modelstate, coly, alphay, colz, alphaz;
	
	// Get 
	if (res = null)
	{
		modelstate = model_state_obj.id
		coly = modelstate.model_preview_color[YP]
		alphay = modelstate.model_preview_alpha[YP]
		colz = modelstate.model_preview_color[ZP]
		alphaz = modelstate.model_preview_alpha[ZP]
	}
	else
	{
		modelstate = null
		coly = null
		alphay = null
		colz = null
		alphaz = null
	}
	
	// Create matrix for rotation
	if (rot[X] > 0 || rot[Z] > 0)
	{
		rotmat = matrix_create(point3D(-block_half_size, -block_half_size, -block_half_size), vec3(0), vec3(1))
		rotmat = matrix_multiply(rotmat, matrix_create(point3D(block_half_size, block_half_size, block_half_size), vec3(-rot[X], 0, -rot[Z]), vec3(1)))
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
		offset = vec3(0)
		
		// Set weight
		weight = wei
		
		// For culling
		for (var f = 0; f < block_faces; f++)
		{
			face_full[f] = false
			face_min[f] = null
			face_max[f] = null
			face_min_depth[f] = null
		}
		
		// For the world importer
		preview_color = array_create(block_faces, null)
		preview_alpha = array_create(block_faces, 0)
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
					for (var f = 0; f < block_faces; f++)
					{
						facenewdir[f] = f
						faceuvrot[f] = 0
					}
					
					light_emission = elem.light_emission
					rotated = elem.rotated
					if (rotated)
						matrix = matrix_multiply(elem.matrix, rotmat)
					else if (rot[X] > 0 || rot[Z] > 0)
					{
						var facerot = rot;
						
						// Rotate points
						from = point3D_mul_matrix(elem.from, rotmat)
						to = point3D_mul_matrix(elem.to, rotmat)
						
						for (var a = X; a <= Z; a++)
						{
							var mi = min(from[a], to[a]);
							var ma = max(from[a], to[a]);
							from[a] = snap(mi, 0.002)
							to[a] = snap(ma, 0.002)
						}
						
						// Invert fixes
						if (abs(elem.volume) > 0)
						{
							var swap;
							for (var a = X; a <= Z; a++)
							{
								if (elem.size[a] > 0)
									continue

								swap = from[a]
								from[a] = to[a]
								to[a] = swap
							}
						}
						
						// Invert rotation
						if ((elem.size[X] < 0 || elem.size[Y] < 0) && elem.size[Z] > 0)
							facerot[Z] = mod_fix(-facerot[Z], 360)
						
						// Shift face references (clockwise, Z -> X)
						repeat (facerot[Z] / 90)
						{
							var eastrotdir = facenewdir[XP];
							facenewdir[XP] = facenewdir[YP]
							facenewdir[YP] = facenewdir[XN]
							facenewdir[XN] = facenewdir[YN]
							facenewdir[YN] = eastrotdir
						}
						
						repeat (facerot[X] / 90)
						{
							var uprotdir = facenewdir[ZP];
							facenewdir[ZP] = facenewdir[YN]
							facenewdir[YN] = facenewdir[ZN]
							facenewdir[ZN] = facenewdir[YP]
							facenewdir[YP] = uprotdir
						}
						
						// Rotate UV by shape rotation
						switch (facerot[X])
						{
							case 0:
							{
								faceuvrot[ZP] = facerot[Z]
								faceuvrot[ZN] = -facerot[Z]
								break
							}
							
							case 90:
							{
								faceuvrot[facenewdir[XP]] = 90
								faceuvrot[facenewdir[XN]] = -90
								faceuvrot[facenewdir[ZP]] = 180
								faceuvrot[ZP] = facerot[Z]
								faceuvrot[ZN] = 180 - facerot[Z]
								break
							}
							
							case 180:
							{
								faceuvrot[XP] = 180
								faceuvrot[XN] = 180
								faceuvrot[YP] = 180
								faceuvrot[YN] = 180
								faceuvrot[ZP] = facerot[Z]
								faceuvrot[ZN] = -facerot[Z]
								break
							}
							
							case 270:
							{
								faceuvrot[facenewdir[XP]] = -90
								faceuvrot[facenewdir[XN]] = 90
								faceuvrot[facenewdir[ZN]] = 180
								faceuvrot[ZP] = 180 + facerot[Z]
								faceuvrot[ZN] = -facerot[Z]
								break
							}
						}
					}
					
					for (var f = 0; f < block_faces; f++)
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
								uvfrom = uv_rotate(elem.face_uv_from[f], -faceuvrot[nd], point2D(block_half_size, block_half_size))
								uvto = uv_rotate(elem.face_uv_to[f], -faceuvrot[nd], point2D(block_half_size, block_half_size))
								
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
								case XP:
								{
									face_uv[nd, 0] = point2D(block_size - to[Y], block_size - to[Z])
									face_uv[nd, 1] = point2D(block_size - from[Y], block_size - to[Z])
									face_uv[nd, 2] = point2D(block_size - from[Y], block_size - from[Z])
									face_uv[nd, 3] = point2D(block_size - to[Y], block_size - from[Z])
									break
								}
								
								case XN:
								{
									face_uv[nd, 0] = point2D(from[Y], block_size - to[Z])
									face_uv[nd, 1] = point2D(to[Y], block_size - to[Z])
									face_uv[nd, 2] = point2D(to[Y], block_size - from[Z])
									face_uv[nd, 3] = point2D(from[Y], block_size - from[Z])
									break
								}
								
								case YP:
								{
									face_uv[nd, 0] = point2D(from[X], block_size - to[Z])
									face_uv[nd, 1] = point2D(to[X], block_size - to[Z])
									face_uv[nd, 2] = point2D(to[X], block_size - from[Z])
									face_uv[nd, 3] = point2D(from[X], block_size - from[Z])
									break
								}
								
								case YN:
								{
									face_uv[nd, 0] = point2D(block_size - to[X], block_size - to[Z])
									face_uv[nd, 1] = point2D(block_size - from[X], block_size - to[Z])
									face_uv[nd, 2] = point2D(block_size - from[X], block_size - from[Z])
									face_uv[nd, 3] = point2D(block_size - to[X], block_size - from[Z])
									break
								}
								
								case ZP:
								{
									face_uv[nd, 0] = point2D(from[X], from[Y])
									face_uv[nd, 1] = point2D(to[X], from[Y])
									face_uv[nd, 2] = point2D(to[X], to[Y])
									face_uv[nd, 3] = point2D(from[X], to[Y])
									break
								}
								
								case ZN:
								{
									face_uv[nd, 0] = point2D(from[X], block_size - to[Y])
									face_uv[nd, 1] = point2D(to[X], block_size - to[Y])
									face_uv[nd, 2] = point2D(to[X], block_size - from[Y])
									face_uv[nd, 3] = point2D(from[X], block_size - from[Y])
									break
								}
							}
							
							// Shift UVs anti-clockwise by face rotation
							if (facerot > 0)
							{
								face_uv[nd, 0] = uv_rotate(face_uv[nd, 0], facerot, point2D(block_half_size, block_half_size))
								face_uv[nd, 1] = uv_rotate(face_uv[nd, 1], facerot, point2D(block_half_size, block_half_size))
								face_uv[nd, 2] = uv_rotate(face_uv[nd, 2], facerot, point2D(block_half_size, block_half_size))
								face_uv[nd, 3] = uv_rotate(face_uv[nd, 3], facerot, point2D(block_half_size, block_half_size))
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
						var texname, texpos, texsize, uvscale;
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
						
						// All?
						if (texname = "all")
						{
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
						face_color_index[nd] = 0
						
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
							uvscale = 1
						}
						else
						{
							// Apply UVs to block sheet/texture
							var slot, slotcode, texturepage, sheetwidth, sheetheight, sheetblocksize;

							face_vbuffer[nd] = null
							
							if (opaque)
								slotcode = mc_assets.block_texture_opaque_slot_map[?texname]
							else
								slotcode = mc_assets.block_texture_slot_map[?texname]
							
							if (is_undefined(slotcode)) // Missing texture, skip face
							{
								face_render[nd] = false
								continue
							}

							texturepage = slotcode mod e_block_sheet.amount
							slot = slotcode div e_block_sheet.amount

							if (texturepage = e_block_sheet.ANIMATED)
							{
								face_depth[nd] = mc_res.block_sheet_ani_depth_list[|slot]
								face_block_vbuffer[nd] = e_block_vbuffer.ANIMATED
								
								// Check color
								var col = mc_assets.block_texture_color_map[?texname];
								if (!is_undefined(col) && col = "water")
								{
									face_depth[nd] = e_block_depth.DEPTH2
									face_block_vbuffer[nd] = e_block_vbuffer.WATER
								}
								
								sheetwidth = minecraft_block_sheet_size[e_block_sheet.ANIMATED][X]
								sheetheight = minecraft_block_sheet_size[e_block_sheet.ANIMATED][Y]
								sheetblocksize = block_size
							}
							else if (texturepage = e_block_sheet.STATIC16)
							{
								face_depth[nd] = mc_res.block_sheet_depth_list[|slot]
								face_block_vbuffer[nd] = e_block_vbuffer.STATIC16
								
								sheetwidth = minecraft_block_sheet_size[e_block_sheet.STATIC16][X]
								sheetheight = minecraft_block_sheet_size[e_block_sheet.STATIC16][Y]
								sheetblocksize = block_size
								
								// Check color
								var col = mc_assets.block_texture_color_map[?texname];
								if (!is_undefined(col))
								{
									if (is_real(col))
										face_color_index[nd] = e_color_palette.amount + ds_list_find_index(mc_assets.block_texture_color_list, col) + 1
									else
									{
										var colorindex = biome_color_name_map[?col];
										if (!is_undefined(colorindex) && colorindex != e_biome_color.WATER)
											face_color_index[nd] = colorindex + 1
									}
								}
							}
							else if (texturepage = e_block_sheet.STATIC32 || texturepage = e_block_sheet.STATIC64)
							{
								// High-resolution sheets are always opaque static faces
								face_depth[nd] = e_block_depth.DEPTH0
								face_block_vbuffer[nd] = (texturepage = e_block_sheet.STATIC32
									? e_block_vbuffer.STATIC32
									: e_block_vbuffer.STATIC64)
								
								sheetwidth = minecraft_block_sheet_size[texturepage][X]
								sheetheight = minecraft_block_sheet_size[texturepage][Y]
								sheetblocksize = block_size_list[texturepage]
							}
							else
							{
								face_render[nd] = false
								continue
							}
							
							texpos = point2D((slot mod sheetwidth) * sheetblocksize, (slot div sheetwidth) * sheetblocksize)
							texsize = vec2(sheetwidth * sheetblocksize, sheetheight * sheetblocksize)
							uvscale = sheetblocksize / block_size
							
							// Get preview color for world importer
							if (res = null)
							{
								if ((nd = ZP && other.preview_color[ZP] = null && alphaz != 0) ||
									(nd = YP && other.preview_color[YP] = null && alphay != 0))
								{
									if (texturepage = e_block_sheet.ANIMATED)
										buffer_current = load_assets_block_preview_ani_buffer
									else
										buffer_current = load_assets_block_preview_buffer[texturepage]
									
									var px, py, alpha;
									px = slot mod sheetwidth
									py = slot div sheetwidth
									
									if (texturepage != e_block_sheet.STATIC16 && texturepage != e_block_sheet.ANIMATED)
									{
										alpha = (nd = ZP ? alphaz : alphay)
										if (alpha = -1)
											alpha = 1
									}
									else if (py < sheetheight && ((nd = ZP && alphaz = -1) || (nd = YP && alphay = -1)))
										alpha = buffer_read_alpha(px, py, sheetwidth)
									else
										alpha = (nd = ZP ? alphaz : alphay)
									
									// Not transparent
									if (alpha > 0)
									{
										var col;
										if ((nd = ZP && colz = -1) || (nd = YP && coly = -1))
											col = buffer_read_color(px, py, sheetwidth)
										else
											col = (nd = ZP ? colz : coly)
										
										var rescol, colstr, tintindex;
										rescol = null
										colstr = ""
										
										tintindex = face_color_index[nd] - 1
										if (face_block_vbuffer[nd] = e_block_vbuffer.WATER)
											tintindex = e_biome_color.WATER

										if (tintindex >= e_color_palette.amount)
											rescol = mc_assets.block_texture_color_list[|tintindex - e_color_palette.amount]

										switch (tintindex)
										{

											case e_biome_color.GRASS:				colstr = "grass"; break
											case e_biome_color.FOLIAGE:				colstr = "foliage"; break
											case e_biome_color.DRY_FOLIAGE:			colstr = "dry_foliage"; break
											case e_biome_color.WATER:				colstr = "water"; break
											case e_biome_color.LEAVES_SPRUCE:		rescol = mc_res.color_list[@ e_biome_color.LEAVES_SPRUCE]; break
											case e_biome_color.LEAVES_BIRCH:		rescol = mc_res.color_list[@ e_biome_color.LEAVES_BIRCH]; break
											case e_biome_color.LEAVES_OAK:
											case e_biome_color.LEAVES_JUNGLE:
											case e_biome_color.LEAVES_ACACIA:
											case e_biome_color.LEAVES_DARK_OAK:
											case e_biome_color.LEAVES_MANGROVE:		colstr = "foliage";	break
											case e_color_palette.PUMPKIN_STEM:		rescol = c_pumpkin_stem; break
											case e_color_palette.MELON_STEM:		rescol = c_melon_stem; break
											case e_color_palette.LILY_PAD:			rescol = c_lily_pad; break
										}
										
										if (rescol != null)
											col = color_multiply(rescol, col)
										
										other.preview_tint = colstr
										other.preview_color[nd] = col
										other.preview_alpha[nd] = alpha
									}
								}
							}
						}
						
						// Apply to UV
						for (var t = 0; t < 4; t++)
						{
							var uv = face_uv[nd, t];
							uv[X] *= uvscale
							uv[Y] *= uvscale
							face_uv[nd, t] = vec2_div(point2D_add(uv, texpos), texsize)
						}
						
						// For culling
						face_edge[nd] = false
						if (!rotated)
						{
							switch (nd)
							{
								case XP:
								case XN:
								{
									if (nd = XP)
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
								
								case YP:
								case YN:
								{
									if (nd = YP)
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
								
								case ZP:
								case ZN:
								{
									if (nd = ZP)
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
					other.element[other.element_amount++] = id
				}
			}
		}
		
		ds_map_destroy(texturemap)
		
		return id
	}
}
