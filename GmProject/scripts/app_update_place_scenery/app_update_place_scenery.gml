/// @desc Adjust position and rotation of placed object by scenery in the world.

function app_update_place_scenery()
{
	// Check for valid scenery
	if (!type_is_block(place_target_tl_root.type))
		return 0

	var worldtransform, blockpos, boxmin, boxmax;
	worldtransform = place_target_tl.matrix_render

	// Find local block position in scenery
	if (place_view_block_pos != null)
		blockpos = place_view_block_pos
	else
	{
		var localpos = point3D_mul_matrix(place_pos, matrix_inverse_ext(worldtransform));
		blockpos = vec3(
			floor((localpos[X] - place_view_normal[X]) / block_size),
			floor((localpos[Y] - place_view_normal[Y]) / block_size),
			floor((localpos[Z] - place_view_normal[Z]) / block_size)
		)
	}

	if (place_view_block_bounds != null)
	{
		boxmin = place_view_block_bounds[0]
		boxmax = place_view_block_bounds[1]
	}
	else
	{
		boxmin = vec3_mul(blockpos, block_size)
		boxmax = vec3_add(boxmin, block_size)	
	}

	var boxcenter, boxsize, facepos, sourceface;
	boxcenter = vec3_mul(vec3_add(boxmin, boxmax), 0.5)
	boxsize = vec3_sub(boxmax, boxmin)
	facepos = vec3_add(boxcenter, vec3_mul(vec3_mul(place_view_normal, boxsize), 0.5))
	sourceface = point3D_mul_matrix(facepos, worldtransform)

	if (place_build)
		place_block_pos = array_copy_1d(blockpos)

	// Assign wireframe box transform
	if (place_build)
	{
		build_box_matrix = matrix_multiply(matrix_create(boxcenter, vec3(0), vec3_div(boxsize, block_size)), worldtransform)
		build_box_render = build_box

		// Select bounds of special block, including transformed parts
		if (place_target_tl_root.type = e_tl_type.SPECIAL_BLOCK)
		{
			var bounds = null;
			with (place_target_tl_root)
				bounds = tl_get_bounds(true)

			if (bounds != null)
			{
				boxcenter = vec3_mul(vec3_add(bounds[0], bounds[1]), 0.5)
				boxsize = vec3_sub(bounds[1], bounds[0])
				build_box_matrix = matrix_create(boxcenter, vec3(0), vec3_div(boxsize, block_size))
			}
			else
				build_box_render = null
		}
	}
	
	// Set rotation
	var worldrotation, worldangle;
	worldrotation = array_copy_1d(worldtransform)
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

		// Anchor a local block position to the clicked block position
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
	{
		var targetoffset = vec3_mul(place_view_normal, block_half_size);
		targetoffset[Z] -= block_half_size
		place_pos = point3D_mul_matrix(vec3_add(facepos, targetoffset), worldtransform)
	}
}
