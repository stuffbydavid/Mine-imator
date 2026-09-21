/// app_update_place_scenery()
/// Adjust position and rotation of placed object by scenery in the world.

function app_update_place_scenery()
{
	// Check for valid scenery
	if (!type_is_block(place_target_tl_part_of.type))
		return 0
		
	var gridsize, worldtransform, localpos, localnormal;
	gridsize = vec3(1);
	if (place_target_tl.type = e_tl_type.SCENERY)
		gridsize = place_target_tl.temp.scenery.scenery_size
	else if (place_target_tl.type = e_tl_type.BLOCK)
		gridsize = place_target_tl.temp.block_repeat_enable ? place_target_tl.temp.block_repeat : vec3(1)

	// Special block model parts use their rendered transform
	if (place_target_tl_part_of.type = e_tl_type.SPECIAL_BLOCK)
		worldtransform = place_target_tl.matrix_render
	else
		worldtransform = matrix_multiply(matrix_create(point3D(0, gridsize[Y] * block_size, 0), vec3(0, 0, 90), vec3(1)), place_target_tl.matrix_render)
		
	localpos = point3D_mul_matrix(place_pos, matrix_inverse_ext(worldtransform))

	// Convert the world-space normal into the scenery grid
	localnormal = vec3_normalize(vec3_mul_matrix(place_view_normal, matrix_transpose(worldtransform)))

	// Find facenormal
	var east, west, south, north, up, down, facenormal, normaldot;
	east = vec3_dot(localnormal, vec3(1, 0, 0))
	west = vec3_dot(localnormal, vec3(-1, 0, 0))
	south = vec3_dot(localnormal, vec3(0, 1, 0))
	north = vec3_dot(localnormal, vec3(0, -1, 0))
	up = vec3_dot(localnormal, vec3(0, 0, 1))
	down = vec3_dot(localnormal, vec3(0, 0, -1))
	facenormal = vec3(1, 0, 0)
	normaldot = east

	if (west > normaldot)
	{
		facenormal = vec3(-1, 0, 0)
		normaldot = west
	}
	if (south > normaldot)
	{
		facenormal = vec3(0, 1, 0)
		normaldot = south
	}
	if (north > normaldot)
	{
		facenormal = vec3(0, -1, 0)
		normaldot = north
	}
	if (up > normaldot)
	{
		facenormal = vec3(0, 0, 1)
		normaldot = up
	}
	if (down > normaldot)
		facenormal = vec3(0, 0, -1)
	
	// Bias the hit into its cell to absorb depth readback error at facenormal boundaries
	var cell, sourceface, worldrotation, worldangle;
	cell = vec3(
		floor((localpos[X] - facenormal[X]) / block_size),
		floor((localpos[Y] - facenormal[Y]) / block_size),
		floor((localpos[Z] - facenormal[Z]) / block_size)
	)
	sourceface = point3D_mul_matrix(vec3(
		(cell[X] + 0.5) * block_size + facenormal[X] * block_half_size,
		(cell[Y] + 0.5) * block_size + facenormal[Y] * block_half_size,
		(cell[Z] + 0.5) * block_size + facenormal[Z] * block_half_size
	), worldtransform)

	worldrotation = array_copy_1d(place_target_tl.matrix_render)
	matrix_remove_scale(worldrotation)
	worldangle = matrix_angle(worldrotation)
	
	place_rot = vec3(radtodeg(worldangle[X]), radtodeg(worldangle[Y]), radtodeg(worldangle[Z]))

	// Adjust final position by size/repeat setting of placed block or scenery
	if ((place_build && build_type = e_tl_type.BLOCK) ||
		(!place_build && (place_tl.type = e_tl_type.BLOCK || (place_tl.type = e_tl_type.SCENERY && place_tl.temp.scenery != null))))
	{
		var targetrepeat, targetmin, targetmax, targetface, legacywidth, targetmatrix, rotpoint;
		if (place_build)
		{
			targetrepeat = build_settings.block_repeat_enable ? build_settings.block_repeat : vec3(1)
			rotpoint = build_settings.rot_point
		}
		else
		{
			targetrepeat = place_tl.temp.block_repeat_enable ? place_tl.temp.block_repeat : vec3(1)
			rotpoint = place_tl.rot_point_render
		}
		targetmin = vec3(0)
		
		if (place_build || place_tl.type = e_tl_type.BLOCK)
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
			if (facenormal[axis] > 0)
				targetface[axis] = targetmin[axis] * block_size
			else if (facenormal[axis] < 0)
				targetface[axis] = targetmax[axis] * block_size
			else
				targetface[axis] = (floor((targetmin[axis] + targetmax[axis]) * 0.5) + 0.5) * block_size
		}
		targetmatrix = matrix_multiply(
			matrix_create(point3D_mul(rotpoint, -1), vec3(0), vec3(1)),
			matrix_create(vec3(0), place_rot, place_sca)
		)
		targetmatrix = matrix_multiply(matrix_create(point3D(0, legacywidth * block_size, 0), vec3(0, 0, 90), vec3(1)), targetmatrix)

		place_pos = point3D_sub(sourceface, point3D_mul_matrix(targetface, targetmatrix))
	}
	else
		place_pos = point3D_mul_matrix(vec3(
			(cell[X] + 0.5 + facenormal[X]) * block_size,
			(cell[Y] + 0.5 + facenormal[Y]) * block_size,
			(cell[Z] + facenormal[Z]) * block_size
		), worldtransform)
}
