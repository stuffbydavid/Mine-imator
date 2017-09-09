/// render_world_scenery(scenery, resource, repeatenable, repeat)
/// @arg scenery
/// @arg resource
/// @arg repeatenable
/// @arg repeat

var scenery, res;
scenery = argument0
res = argument1

if (!scenery.ready)
	return 0
	
if (argument2) // Repeat
{
	var rep, mat, reppos;
	rep = argument3
	mat = matrix_get(matrix_world)
	for (reppos[X] = 0; reppos[X] < rep[X]; reppos[X]++)
	{
		for (reppos[Y] = 0; reppos[Y] < rep[Y]; reppos[Y]++)
		{
			for (reppos[Z] = 0; reppos[Z] < rep[Z]; reppos[Z]++)
			{
				var pos = vec3_mul(scenery.scenery_size, point3D_mul(reppos, block_size))
				matrix_set(matrix_world, matrix_multiply(matrix_create(pos, vec3(0), vec3(1)), mat))
				render_world_block(scenery.block_vbuffer, scenery.scenery_size, res)
			}
		}
	}
}
else
	render_world_block(scenery.block_vbuffer, scenery.scenery_size, res)

