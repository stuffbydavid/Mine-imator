/// @desc Returns the legacy block mesh transform.

function render_world_block_transform(ysize = 1)
{
	return matrix_create(point3D(0, ysize * block_size, 0), vec3(0, 0, 90), vec3(1))
}
