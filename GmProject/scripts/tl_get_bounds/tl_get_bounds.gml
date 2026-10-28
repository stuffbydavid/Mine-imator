/// @desc Returns the timeline's world bounds as two points, or null if unavailable.

function tl_get_bounds()
{
	var halfsize, center, extent;
	halfsize = vec3(block_half_size)
	center = world_pos

	if (type = e_tl_type.SCENERY)
	{
		var res, rep, offset, blockmin, blockmax;
		res = (temp != null ? temp.scenery : null)
		if (res = null || !res.ready)
			return null

		rep = temp.block_repeat_enable ? temp.block_repeat : vec3(1)

		if (array_length(block_meshes_edit) > 0)
		{
			blockmin = block_meshes_min_pos
			blockmax = block_meshes_max_pos
		}
		else
		{
			blockmin = vec3(0)
			blockmax = vec3(
				res.scenery_size[X] * max(1, ceil(rep[X])),
				res.scenery_size[Y] * max(1, ceil(rep[Y])),
				res.scenery_size[Z] * max(1, ceil(rep[Z]))
			)
		}

		halfsize = vec3_mul(vec3_sub(blockmax, blockmin), block_half_size)
		offset = vec3_mul(blockmin, block_size)
		center = point3D_mul_matrix(vec3_add(halfsize, offset), matrix_render)
	}

	// Project the size onto the world axes
	var extentmatrix = array_copy_1d(matrix_render);
	for (var i = 0; i < 12; i++)
		extentmatrix[@i] = abs(extentmatrix[@i])

	extent = vec3_mul_matrix(halfsize, extentmatrix)

	return [ point3D_sub(center, extent), point3D_add(center, extent) ]
}
