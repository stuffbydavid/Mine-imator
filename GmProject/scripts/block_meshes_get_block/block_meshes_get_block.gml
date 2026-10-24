/// @desc Returns the block and state ID at a world position.
/// @arg position

function block_meshes_get_block(worldpos)
{
	var res, cell, rep;
	res = temp.scenery
	if (res = null || !res.ready)
		return [ 0, 0 ]

	// Find the cell in the scenery's local coordinates
	cell = point3D_mul_matrix(worldpos, matrix_inverse_ext(matrix_render))
	rep = temp.block_repeat_enable ? temp.block_repeat : vec3(1)
	for (var a = X; a <= Z; a++)
	{
		cell[@a] = floor(cell[a] / block_size)
		if (res.scenery_size[a] <= 0 || cell[a] < 0 || cell[a] >= res.scenery_size[a] * rep[a])
			return [ 0, 0 ]

		cell[@a] = cell[a] mod res.scenery_size[a]
	}

	// Undo the builder-to-render transform: rendered X = builder Y, rendered Y = width - builder X
	cell = vec3(res.scenery_size[Y] - 1 - cell[Y], cell[X], cell[Z])

	var mesh, meshindex, loaded;
	mesh = null
	loaded = false
	while (mesh = null)
	{
		meshindex = block_mesh_get_index(cell[X], cell[Y], cell[Z], res.block_meshes_size[X], res.block_meshes_size[Y])
		if (meshindex < array_length(res.block_meshes))
			mesh = res.block_meshes[meshindex]

		if (mesh != null && mesh.block_palette_buffer != null && mesh.block_grid_buffer != null)
			break

		// Load synchronously once, leaving the cached geometry and timelines intact
		if (loaded)
			return [ 0, 0 ]

		with (res)
			loaded = res_load_scenery_file(app.project_folder + "/" + filename, true)

		if (!loaded)
		{
			error("error/load_schematic")
			return [ 0, 0 ]
		}

		mesh = null
	}

	// Decode the cell's packed palette index, including indices crossing byte boundaries
	var count, bits, pos, bitpos, remaining, index, shift;
	count = buffer_get_size(mesh.block_palette_buffer) div 4
	bits = 0
	while (power(2, bits) < count)
		bits++

	pos = ((cell[Z] mod block_mesh_size) * mesh.block_grid_size[Y] + (cell[Y] mod block_mesh_size)) * mesh.block_grid_size[X] + (cell[X] mod block_mesh_size)
	bitpos = pos * bits
	remaining = bits
	index = 0
	shift = 0
	while (remaining > 0)
	{
		var offset, take, byte;
		offset = bitpos mod 8
		take = min(remaining, 8 - offset)
		byte = buffer_peek(mesh.block_grid_buffer, bitpos div 8, buffer_u8)
		index = index | (((byte >> offset) & ((1 << take) - 1)) << shift)
		bitpos += take
		shift += take
		remaining -= take
	}

	var blockid, stateid;
	blockid = buffer_peek(mesh.block_palette_buffer, index * 4, buffer_u16)
	stateid = buffer_peek(mesh.block_palette_buffer, index * 4 + 2, buffer_u16)

	return [ blockid, stateid ]
}
