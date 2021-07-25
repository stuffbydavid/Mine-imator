/// render_world_scenery(scenery, resource, repeatenable, repeat)
/// @arg scenery
/// @arg resource
/// @arg repeatenable
/// @arg repeat

function render_world_scenery(scenery, res, repeatenable, rep)
{
	if (!scenery.ready)
		return 0
	
	render_repeat = [0, 0, 0]
	
	if (repeatenable) // Repeat
	{
		var mat, reppos, defrot, defscale;
		mat = matrix_get(matrix_world)
		defrot = [0, 0, 0]
		defscale = [1, 1, 1]
		
		for (reppos[X] = 0; reppos[X] < rep[X]; reppos[X]++)
		{
			for (reppos[Y] = 0; reppos[Y] < rep[Y]; reppos[Y]++)
			{
				for (reppos[Z] = 0; reppos[Z] < rep[Z]; reppos[Z]++)
				{
					render_repeat = reppos
					
					var pos = vec3_mul(scenery.scenery_size, point3D_mul(reppos, block_size))
					matrix_set(matrix_world, matrix_multiply(matrix_create(pos, defrot, defscale), mat))
					render_world_block(scenery.scenery_chunk_array, res, true, scenery.scenery_size)
					
					if (id.object_index != obj_preview)
						render_set_uniform("uRoughness", value_inherit[e_value.ROUGHNESS])
				}
			}
		}
	}
	else
		render_world_block(scenery.scenery_chunk_array, res, true, scenery.scenery_size)
}
