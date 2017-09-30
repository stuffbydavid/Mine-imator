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
rotmat = matrix_create(point3D(-block_size / 2, -block_size / 2, -block_size / 2), vec3(0), vec3(1))
rotmat = matrix_multiply(rotmat, matrix_create(point3D(block_size / 2, block_size / 2, block_size / 2), vec3(-rot[X], 0, -rot[Z]), vec3(1)))

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
	offset = point3D(0, 0, 0)
	
	// Set weight
	weight = wei
	
	// Add elements
	element_amount = 0
	if (elementmodel != null)
	{
		for (var e = 0; e < elementmodel.element_amount; e++)
		{
			var relem = new(obj_block_render_element);
			
			// Generate render element from loaded element
			with (elementmodel.element[e])
			{
				var facerot, facenewdir;
				relem.from = from
				relem.to = to
				relem.matrix = matrix_multiply(matrix, rotmat)
				relem.rot_from = point3D_mul_matrix(from, rotmat)
				relem.rot_to = point3D_mul_matrix(to, rotmat)
				relem.rotated = rotated
				
				for (var a = X; a <= Z; a++)
				{
					var mi = min(relem.rot_from[a], relem.rot_to[a]);
					var ma = max(relem.rot_from[a], relem.rot_to[a]);
					relem.rot_from[a] = snap(mi, 0.01)
					relem.rot_to[a] = snap(ma, 0.01)
				}
				
				// Set face rotations and rotated directions
				for (var f = 0; f < e_dir.amount; f++)
				{
					facerot[f] = 0
					facenewdir[f] = f
				}
				
				// Apply rotation to UV
				if (rot[X] > 0 || rot[Z] > 0)
				{
					// Apply to texture if UV locked
					if (uvlock)
					{
						facerot[e_dir.EAST] = rot[X]
						facerot[e_dir.WEST] = rot[X]
						
						switch (rot[X])
						{
							case 0:
								facerot[e_dir.UP] = -rot[Z]
								facerot[e_dir.DOWN] = rot[Z]
								break

							case 90:
								facerot[e_dir.SOUTH] = 90 + rot[Z] // Up
								facerot[e_dir.NORTH] = -90 - rot[Z] // Down
								facerot[e_dir.UP] = 90	// North
								facerot[e_dir.DOWN] = -90 // South
								break

							case 180:
								facerot[e_dir.SOUTH] = 180 // North
								facerot[e_dir.NORTH] = 180 // South
								facerot[e_dir.UP] = rot[Z] // Down
								facerot[e_dir.DOWN] = -rot[Z] // Up
								break

							case 270:
								facerot[e_dir.SOUTH] = 90 - rot[Z] // Down
								facerot[e_dir.NORTH] = -90 + rot[Z] // Up
								facerot[e_dir.UP] = -90 // South
								facerot[e_dir.DOWN] = 90 // North
								break
						}
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
				}
				
				for (var f = 0; f < e_dir.amount; f++)
				{
					var nd = facenewdir[f];
					
					// Render
					relem.face_render[f] = face_render[f]
					relem.rot_face_render[nd] = face_render[f]
					if (!relem.face_render[f])
						continue
						
					// UV
					if (face_has_uv[f])
					{
						var uvfrom, uvto;
						uvfrom = face_uv_from[f]
						uvto = face_uv_to[f]
						relem.face_uv[f, 0] = uvfrom
						relem.face_uv[f, 1] = point2D(uvto[X], uvfrom[Y])
						relem.face_uv[f, 2] = uvto
						relem.face_uv[f, 3] = point2D(uvfrom[X], uvto[Y])
					}
					
					// Auto generate UVs
					else
					{
						switch (f)
						{
							case e_dir.EAST:
								relem.face_uv[f, 0] = point2D(block_size - relem.to[Y], block_size - relem.to[Z])
								relem.face_uv[f, 1] = point2D(block_size - relem.from[Y], block_size - relem.to[Z])
								relem.face_uv[f, 2] = point2D(block_size - relem.from[Y], block_size - relem.from[Z])
								relem.face_uv[f, 3] = point2D(block_size - relem.to[Y], block_size - relem.from[Z])
								break

							case e_dir.WEST:
								relem.face_uv[f, 0] = point2D(relem.from[Y], block_size - relem.to[Z])
								relem.face_uv[f, 1] = point2D(relem.to[Y], block_size - relem.to[Z])
								relem.face_uv[f, 2] = point2D(relem.to[Y], block_size - relem.from[Z])
								relem.face_uv[f, 3] = point2D(relem.from[Y], block_size - relem.from[Z])
								break
								
							case e_dir.SOUTH:
								relem.face_uv[f, 0] = point2D(relem.from[X], block_size - relem.to[Z])
								relem.face_uv[f, 1] = point2D(relem.to[X], block_size - relem.to[Z])
								relem.face_uv[f, 2] = point2D(relem.to[X], block_size - relem.from[Z])
								relem.face_uv[f, 3] = point2D(relem.from[X], block_size - relem.from[Z])
								break

							case e_dir.NORTH:
								relem.face_uv[f, 0] = point2D(block_size - relem.to[X], block_size - relem.to[Z])
								relem.face_uv[f, 1] = point2D(block_size - relem.from[X], block_size - relem.to[Z])
								relem.face_uv[f, 2] = point2D(block_size - relem.from[X], block_size - relem.from[Z])
								relem.face_uv[f, 3] = point2D(block_size - relem.to[X], block_size - relem.from[Z])
								break
						
							case e_dir.UP:
								relem.face_uv[f, 0] = point2D(relem.from[X], relem.from[Y])
								relem.face_uv[f, 1] = point2D(relem.to[X], relem.from[Y])
								relem.face_uv[f, 2] = point2D(relem.to[X], relem.to[Y])
								relem.face_uv[f, 3] = point2D(relem.from[X], relem.to[Y])
								break
								
							case e_dir.DOWN:
								relem.face_uv[f, 0] = point2D(relem.from[X], block_size - relem.to[Y])
								relem.face_uv[f, 1] = point2D(relem.to[X], block_size - relem.to[Y])
								relem.face_uv[f, 2] = point2D(relem.to[X], block_size - relem.from[Y])
								relem.face_uv[f, 3] = point2D(relem.from[X], block_size - relem.from[Y])
								break
						}
					}
					
					// Rotate UVs
					if (facerot[f] <> 0)
						for (var t = 0; t < 4; t++)
							relem.face_uv[f, t] = uv_rotate(relem.face_uv[f, t], facerot[f], point2D(block_size / 2, block_size / 2))
					
					// Shift UVs
					repeat (face_rotation[f] / 90)
					{
						var tmp = relem.face_uv[f, 0];
						relem.face_uv[f, 0] = relem.face_uv[f, 3]
						relem.face_uv[f, 3] = relem.face_uv[f, 2]
						relem.face_uv[f, 2] = relem.face_uv[f, 1]
						relem.face_uv[f, 1] = tmp
					}
					
					// Texture
					var texname;
					if (uvlock && face_render[nd]) // Keep texture on UV lock
						texname = face_texture[nd]
					else
						texname = face_texture[f]
					while (string_char_at(texname, 1) = "#") // Fetch from map
						texname = texturemap[?string_delete(texname, 1, 1)]
						
					// Texture color
					relem.face_texture_color[f] = -1
					
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
							relem.face_render[f] = false
							relem.rot_face_render[nd] = false
							continue
						}
						
						relem.face_depth[f] = res_def.block_sheet_ani_depth_list[|slot]
						relem.face_vbuffer[f] = e_block_vbuffer.ANIMATED
						sheetwidth = block_sheet_ani_width
						sheetheight = block_sheet_ani_height
					}
					else
					{
						relem.face_depth[f] = res_def.block_sheet_depth_list[|slot]
						relem.face_vbuffer[f] = e_block_vbuffer.NORMAL
						sheetwidth = block_sheet_width
						sheetheight = block_sheet_height
						
						// Check color
						var col = mc_assets.block_texture_color_map[?texname];
						if (!is_undefined(col))
						{
							if (is_real(col))
								relem.face_texture_color[f] = col
							else if (col = "grass")
								relem.face_vbuffer[f] = e_block_vbuffer.GRASS
							else if (col = "leaves")
								relem.face_vbuffer[f] = e_block_vbuffer.LEAVES
						}
					}
					
					slotpos = point2D((slot mod sheetwidth) * block_size, (slot div sheetwidth) *  block_size)
					texsize = vec2(1 / (sheetwidth * block_size), 1 / (sheetheight * block_size))
					
					// Apply to UV
					for (var t = 0; t < 4; t++)
						relem.face_uv[f, t] = vec2_mul(point2D_add(relem.face_uv[f, t], slotpos), texsize)
						
					// For cull test
					if (face_cullface[f] = null)
						relem.face_rot_cullface[f] = null
					else
						relem.face_rot_cullface[f] = facenewdir[face_cullface[f]]
					relem.rot_face_depth[nd] = relem.face_depth[f]
				}
			}
			
			element[element_amount++] = relem
		}
	}
	
	ds_map_destroy(texturemap)
	return id
}