/// @desc Adjust position and rotation of placed object by scenery in the world.

function app_update_place_scenery()
{
	// Check for valid scenery
	if (!type_is_block(place_target_tl_part_of.type))
		return 0

	var worldtransform, inversetransform, localpos;
	worldtransform = place_target_tl.matrix_render
	inversetransform = matrix_inverse_ext(worldtransform)
	localpos = point3D_mul_matrix(place_pos, inversetransform)

	if (place_build)
	{
		// Trace into the target before rounding to its local cell
		var localray, tracenormal, inside, boxcell, boxcenter;
		localray = vec3_normalize(vec3_mul_matrix(place_view_ray, inversetransform))
		tracenormal = vec3_normalize(vec3_sub(localray, place_view_normal))
		inside = vec3_add(localpos, vec3_mul(tracenormal, block_size * 0.025))
		boxcell = vec3(
			round(inside[X] / block_size - 0.5),
			round(inside[Y] / block_size - 0.5),
			round(inside[Z] / block_size - 0.5)
		)
		boxcenter = vec3_mul(vec3_add(boxcell, 0.5), block_size)
		build_box_matrix = matrix_multiply(matrix_create(boxcenter, vec3(0), vec3(1)), worldtransform)
		build_box_render = build_box
	}
	
	// Bias the hit into its cell to absorb depth readback error at face boundaries
	var cell, sourceface, worldrotation, worldangle;
	cell = vec3(
		floor((localpos[X] - place_view_normal[X]) / block_size),
		floor((localpos[Y] - place_view_normal[Y]) / block_size),
		floor((localpos[Z] - place_view_normal[Z]) / block_size)
	)
	sourceface = point3D_mul_matrix(vec3(
		(cell[X] + 0.5) * block_size + place_view_normal[X] * block_half_size,
		(cell[Y] + 0.5) * block_size + place_view_normal[Y] * block_half_size,
		(cell[Z] + 0.5) * block_size + place_view_normal[Z] * block_half_size
	), worldtransform)

	worldrotation = array_copy_1d(place_target_tl.matrix_render)
	matrix_remove_scale(worldrotation)
	worldangle = matrix_angle(worldrotation)
	
	place_rot = vec3(radtodeg(worldangle[X]), radtodeg(worldangle[Y]), radtodeg(worldangle[Z]))

	// Adjust final position by size/repeat setting of placed block or scenery
	if ((place_build && build_type = e_tl_type.BLOCK) ||
		(!place_build && (place_tl.type = e_tl_type.BLOCK || (place_tl.type = e_tl_type.SCENERY && place_tl.temp.scenery != null))))
	{
		var targetrepeat, targetmax, targetface, targetmatrix, rotpoint;
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
		
		if (place_build || place_tl.type = e_tl_type.BLOCK)
			targetmax = targetrepeat
		else
			targetmax = vec3_mul(place_tl.temp.scenery.scenery_size, targetrepeat)

		// Anchor a local cell to the clicked cell
		targetface = vec3(0)
		for (var axis = X; axis <= Z; axis++)
		{
			if (place_view_normal[axis] > 0)
				targetface[axis] = 0
			else if (place_view_normal[axis] < 0)
				targetface[axis] = targetmax[axis] * block_size
			else
				targetface[axis] = (axis = Y ? ceil(targetmax[axis] * 0.5) - 0.5 : floor(targetmax[axis] * 0.5) + 0.5) * block_size
		}
		targetmatrix = matrix_multiply(
			matrix_create(point3D_mul(rotpoint, -1), vec3(0), vec3(1)),
			matrix_create(vec3(0), place_rot, place_sca)
		)

		place_pos = point3D_sub(sourceface, point3D_mul_matrix(targetface, targetmatrix))
	}
	else
		place_pos = point3D_mul_matrix(vec3(
			(cell[X] + 0.5 + place_view_normal[X]) * block_size,
			(cell[Y] + 0.5 + place_view_normal[Y]) * block_size,
			(cell[Z] + place_view_normal[Z]) * block_size
		), worldtransform)
}
