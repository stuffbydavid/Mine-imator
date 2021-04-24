/// render_world_scenery(scenery, resource, repeatenable, repeat)
/// @arg scenery
/// @arg resource
/// @arg repeatenable
/// @arg repeat

function render_world_scenery(scenery, res, repeatenable, rep)
{
	if (!scenery.ready)
		return 0
	
	if (repeatenable) // Repeat
	{
		var mat, reppos;
		mat = matrix_get(matrix_world)
		for (reppos[X] = 0; reppos[X] < rep[X]; reppos[X]++)
		{
			for (reppos[Y] = 0; reppos[Y] < rep[Y]; reppos[Y]++)
			{
				for (reppos[Z] = 0; reppos[Z] < rep[Z]; reppos[Z]++)
				{
					var pos = vec3_mul(scenery.scenery_size, point3D_mul(reppos, block_size))
					matrix_set(matrix_world, matrix_multiply(matrix_create(pos, vec3(0), vec3(1)), mat))
					render_world_block(scenery.block_vbuffer, res, true, scenery.scenery_size)
				}
			}
		}
	}
	else
		render_world_block(scenery.block_vbuffer, res, true, scenery.scenery_size)
}
