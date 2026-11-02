/// @desc Returns a timeline placement matrix in scenery-local coordinates.
/// @arg block
/// @arg stateid
/// @arg [blockposition]

function block_get_timeline_matrix(block, stateid, blockpos = null)
{
	var pos, rotation;
	pos = block_get_timeline_position(block, stateid)
	rotation = block_get_timeline_rotation(block, stateid)

	// Convert the timeline position and rotation from builder to scenery axes
	pos = vec3(pos[Y], block_size - pos[X], pos[Z])
	rotation = vec3_add(rotation, vec3(0, 0, 90))
	if (blockpos != null)
		pos = vec3_add(pos, vec3_mul(blockpos, block_size))

	return matrix_create(pos, rotation, vec3(1))
}
