/// @desc Returns block data at a structure position, including placed block timelines.
/// @arg target
/// @arg position

function block_build_get_block(target, blockpos)
{
	if (target = null)
		return [ 0, 0, false ]

	var data = [ 0, 0, false ];
	with (target)
		data = block_meshes_get_block(blockpos[X], blockpos[Y], blockpos[Z])
	
	if (data[0] != 0 || ds_list_size(target.tree_list) = 0)
		return data

	// Independent timelines can also support newly placed blocks
	var inverse = matrix_inverse_ext(target.matrix_render);
	for (var i = 0; i < ds_list_size(target.tree_list); i++)
	{
		var tl = target.tree_list[|i];
		if (tl.block_build_name = "" || tl.block_timeline)
			continue

		var current = null;
		with (tl)
			current = tl_get_build_block()
		
		if (current = null)
			continue

		var block, stateid, origin, offset;
		block = block_objs[current[0]]
		stateid = current[1]
		
		var pos = block_get_timeline_position(block, stateid);
		offset = vec3(pos[Y], block_size - pos[X], pos[Z])

		origin = point3D_mul_matrix(matrix_position(tl.matrix), inverse)
		origin = vec3_sub(origin, offset)
		origin = vec3(floor(origin[X] / block_size + 0.001), floor(origin[Y] / block_size + 0.001), floor(origin[Z] / block_size + 0.001))
		
		var occupied = block_build_get_connect(block, stateid, origin);
		
		for (var c = 0; c < array_length(occupied); c++)
			if (vec3_equals(occupied[c][0], blockpos))
				return [ occupied[c][1], occupied[c][2], false ]
	}

	return data
}
