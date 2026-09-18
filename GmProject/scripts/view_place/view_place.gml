/// view_place(view, camera)
/// @arg view
/// @arg camera

function view_place(view, cam)
{
	if (window_busy != "place" || mouse_x < content_x || mouse_y < content_y || mouse_x >= content_x + content_width || mouse_y >= content_y + content_height)
		return

	var surfaceid, surfacenormal, surfacedepth;
	surfaceid = view.surface_place_id
	surfacenormal = view.surface_place_normal
	surfacedepth = view.surface_place_depth_gm
	view.surface_place_id = surface_require(view.surface_place_id, content_width, content_height)
	view.surface_place_normal = surface_require(view.surface_place_normal, content_width, content_height, false)
	if (!is_cpp())
		view.surface_place_depth_gm = surface_require(view.surface_place_depth_gm, content_width, content_height, false)
	if (view.surface_place_id != surfaceid || view.surface_place_normal != surfacenormal ||
		(!is_cpp() && view.surface_place_depth_gm != surfacedepth) ||
		view.surface_place_width != content_width || view.surface_place_height != content_height)
		view.update_place_surfaces = true
	view.surface_place_width = content_width
	view.surface_place_height = content_height

	// Update placement surfaces with placed object hidden
	if (view.update_place_surfaces)
	{
		render_start(null, null, content_width, content_height) // No camera to disable effects
		render_camera = cam
		render_update_camera()
		place_tl_render = false
		
		// Render timeline IDs and normals
		if (is_cpp())
			surface_clear_depth_cache(view.surface_place_id)
		surface_set_target_ext(0, view.surface_place_id)
		surface_set_target_ext(1, view.surface_place_normal)
		if (!is_cpp())
			surface_set_target_ext(2, view.surface_place_depth_gm)
		{
			gpu_set_blendmode_ext(bm_one, bm_zero)
			draw_clear_alpha(c_black, 0)
			render_world_start()
			render_world(e_render_mode.PLACE)
			render_world_done()
			gpu_set_blendmode(bm_normal)
		}
		surface_reset_target()
		
		render_done()
		view.update_place_surfaces = false
		place_tl_render = true
	}

	var mx, my, tx, ty, depthval, normal, normalface, worldtransform, localpos;
	mx = mouse_x - content_x
	my = mouse_y - content_y
	tx = mx / content_width
	ty = 1 - my / content_height
	
	// C++ path uses optimized depth lookup
	if (is_cpp())
		depthval = surface_get_depth(view.surface_place_id, mx, my)
	else
	{
		// GameMaker path uses packed depth value in color
		var packeddepth;
		packeddepth = surface_getpixel(view.surface_place_depth_gm, mx, my)
		depthval = 1 - (color_get_red(packeddepth) / 255 + color_get_green(packeddepth) / (255 * 255) + color_get_blue(packeddepth) / (255 * 255 * 255))
	}
	
	view.place_depth_value = depthval
	normal = null
	normalface = null
	worldtransform = null
	localpos = null
	view.place_target_tl = null
	view.place_target_tl_part_of = null
	
	if (depthval < 1)
	{
		var color, normalpacked;
		color = surface_getpixel(view.surface_place_id, mx, my)
		if (color > 0)
		{
			view.place_target_tl = color
			view.place_target_tl_part_of = color
			
			// Retrieve containing model
			if (view.place_target_tl.type = e_tl_type.MODEL_PART && view.place_target_tl.part_of != null)
				view.place_target_tl_part_of = view.place_target_tl.part_of
		}
		
		normalpacked = surface_getpixel(view.surface_place_normal, mx, my)
		normal = vec3_normalize(vec3(
			color_get_red(normalpacked) / 255 * 2 - 1,
			color_get_green(normalpacked) / 255 * 2 - 1,
			color_get_blue(normalpacked) / 255 * 2 - 1
		))
	}

	var maxdepth, clipspace, viewspace;
	maxdepth = 0.99975
	clipspace = vec4(tx * 2 - 1, ty * 2 - 1, min(maxdepth, depthval) * 2 - 1, 1)
	viewspace = vec4_homogenize(vec4_mul_matrix(clipspace, matrix_inverse_ext(proj_matrix)))
	
	place_view_pos = point3D_mul_matrix(viewspace, matrix_inverse_ext(view_matrix))
	place_view_rot = vec3(0)
	place_view_sca = vec3(1)

	if (view.place_target_tl != null &&
		(view.place_target_tl.type = e_tl_type.SCENERY || view.place_target_tl.type = e_tl_type.BLOCK || view.place_target_tl_part_of.type = e_tl_type.SPECIAL_BLOCK))
	{
		var gridsize = vec3(1);
		if (view.place_target_tl.type = e_tl_type.SCENERY)
			gridsize = view.place_target_tl.temp.scenery.scenery_size
		else if (view.place_target_tl.type = e_tl_type.BLOCK)
			gridsize = view.place_target_tl.temp.block_repeat_enable ? view.place_target_tl.temp.block_repeat : vec3(1)

		// Special block model parts use their rendered transform
		if (view.place_target_tl_part_of.type = e_tl_type.SPECIAL_BLOCK)
			worldtransform = view.place_target_tl.matrix_render
		else
			worldtransform = matrix_multiply(matrix_create(point3D(0, gridsize[Y] * block_size, 0), vec3(0, 0, 90), vec3(1)), view.place_target_tl.matrix_render)
		localpos = point3D_mul_matrix(place_view_pos, matrix_inverse_ext(worldtransform))

		// Convert the world-space normal into the scenery grid
		normal = vec3_normalize(vec3_mul_matrix(normal, matrix_transpose(worldtransform)))
	}

	if (normal != null)
	{
		var east, west, south, north, up, down, normalindex, normaldot;
		east = vec3_dot(normal, vec3(1, 0, 0))
		west = vec3_dot(normal, vec3(-1, 0, 0))
		south = vec3_dot(normal, vec3(0, 1, 0))
		north = vec3_dot(normal, vec3(0, -1, 0))
		up = vec3_dot(normal, vec3(0, 0, 1))
		down = vec3_dot(normal, vec3(0, 0, -1))
		normalindex = 0
		normaldot = east

		if (west > normaldot)
		{
			normalindex = 1
			normaldot = west
		}
		if (south > normaldot)
		{
			normalindex = 2
			normaldot = south
		}
		if (north > normaldot)
		{
			normalindex = 3
			normaldot = north
		}
		if (up > normaldot)
		{
			normalindex = 4
			normaldot = up
		}
		if (down > normaldot)
			normalindex = 5

		switch (normalindex)
		{
			case 0: normalface = e_dir.EAST break
			case 1: normalface = e_dir.WEST break
			case 2: normalface = e_dir.SOUTH break
			case 3: normalface = e_dir.NORTH break
			case 4: normalface = e_dir.UP break
			case 5: normalface = e_dir.DOWN break
		}
	}

	view.place_depth_face = normalface
	
	if (view.place_depth_value < maxdepth) // Non-air placement
	{
		// Ground placement
		if (view.place_target_tl = null)
		{
			var rotpoint = point3D(block_half_size, block_half_size, 0);
			if (place_tl != null && (place_tl.type = e_tl_type.BLOCK || place_tl.type = e_tl_type.SCENERY))
				rotpoint = place_tl.rot_point_render

			place_view_pos[X] = snap(place_view_pos[X] - rotpoint[X], block_size) + rotpoint[X]
			place_view_pos[Y] = snap(place_view_pos[Y] - rotpoint[Y], block_size) + rotpoint[Y]
			place_view_pos[Z] = 0
		}
		else if (worldtransform != null) // Minecraft grid placement
		{
			var face, cell, sourceface, worldrotation, worldangle;
			switch (normalface)
			{
				case e_dir.EAST: face = vec3(1, 0, 0); break
				case e_dir.WEST: face = vec3(-1, 0, 0); break
				case e_dir.SOUTH: face = vec3(0, 1, 0); break
				case e_dir.NORTH: face = vec3(0, -1, 0); break
				case e_dir.UP: face = vec3(0, 0, 1); break
				case e_dir.DOWN: face = vec3(0, 0, -1); break
			}

			// Bias the hit into its cell to absorb depth readback error at face boundaries
			cell = vec3(
				floor((localpos[X] - face[X]) / block_size),
				floor((localpos[Y] - face[Y]) / block_size),
				floor((localpos[Z] - face[Z]) / block_size)
			)
			sourceface = point3D_mul_matrix(vec3(
				(cell[X] + 0.5) * block_size + face[X] * block_half_size,
				(cell[Y] + 0.5) * block_size + face[Y] * block_half_size,
				(cell[Z] + 0.5) * block_size + face[Z] * block_half_size
			), worldtransform)

			worldrotation = array_copy_1d(view.place_target_tl.matrix_render)
			matrix_remove_scale(worldrotation)
			worldangle = matrix_angle(worldrotation)
			place_view_rot = vec3(radtodeg(worldangle[X]), radtodeg(worldangle[Y]), radtodeg(worldangle[Z]))

			// Adjust final position by size/repeat setting of current block or scenery
			if (place_tl.type = e_tl_type.BLOCK || (place_tl.type = e_tl_type.SCENERY && place_tl.temp.scenery != null))
			{
				var targetrepeat, targetmin, targetmax, targetface, legacywidth, targetmatrix;
				targetrepeat = place_tl.temp.block_repeat_enable ? place_tl.temp.block_repeat : vec3(1)
				targetmin = vec3(0)
				if (place_tl.type = e_tl_type.BLOCK)
				{
					targetmax = vec3(targetrepeat[Y], targetrepeat[X], targetrepeat[Z])
					legacywidth = targetrepeat[Y]
				}
				else
				{
					var scenerysize = place_tl.temp.scenery.scenery_size
					targetmin[X] = (1 - targetrepeat[Y]) * scenerysize[Y]
					targetmax = vec3(scenerysize[Y], targetrepeat[X] * scenerysize[X], targetrepeat[Z] * scenerysize[Z])
					legacywidth = scenerysize[Y]
				}

				// Anchor a local cell to the clicked cell
				targetface = vec3(0)
				for (var axis = X; axis <= Z; axis++)
				{
					if (face[axis] > 0)
						targetface[axis] = targetmin[axis] * block_size
					else if (face[axis] < 0)
						targetface[axis] = targetmax[axis] * block_size
					else
						targetface[axis] = (floor((targetmin[axis] + targetmax[axis]) * 0.5) + 0.5) * block_size
				}
				targetmatrix = matrix_multiply(
					matrix_create(point3D_mul(place_tl.rot_point_render, -1), vec3(0), vec3(1)),
					matrix_create(vec3(0), place_view_rot, vec3(place_tl.value[e_value.SCA_X], place_tl.value[e_value.SCA_Y], place_tl.value[e_value.SCA_Z]))
				)
				targetmatrix = matrix_multiply(matrix_create(point3D(0, legacywidth * block_size, 0), vec3(0, 0, 90), vec3(1)), targetmatrix)

				place_view_pos = point3D_sub(sourceface, point3D_mul_matrix(targetface, targetmatrix))
			}
			else
				place_view_pos = point3D_mul_matrix(vec3(
					(cell[X] + 0.5 + face[X]) * block_size,
					(cell[Y] + 0.5 + face[Y]) * block_size,
					(cell[Z] + face[Z]) * block_size
				), worldtransform)
		}
	}
	
	render_samples = -1
}
