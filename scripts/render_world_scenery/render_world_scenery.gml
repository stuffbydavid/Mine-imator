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
		var mat, reppos, defrot, defscale;
		mat = matrix_get(matrix_world)
		reppos = [0, 0, 0]
		defrot = [0, 0, 0]
		defscale = [1, 1, 1]
		
		for (reppos[X] = 0; reppos[X] < rep[X]; reppos[X]++)
		{
			for (reppos[Y] = 0; reppos[Y] < rep[Y]; reppos[Y]++)
			{
				for (reppos[Z] = 0; reppos[Z] < rep[Z]; reppos[Z]++)
				{
					var pos = vec3_mul(scenery.scenery_size, point3D_mul(reppos, block_size))
					matrix_set(matrix_world, matrix_multiply(matrix_create(pos, defrot, defscale), mat))
					render_world_block(scenery.block_vbuffer, res, true, scenery.scenery_size)
					
					if (id.object_index != obj_preview)
					{
						if (value_inherit[e_value.ROUGHNESS] != shader_uniform_roughness)
						{
							shader_uniform_roughness = value_inherit[e_value.ROUGHNESS]
							render_set_uniform("uRoughness", shader_uniform_roughness)
						}
						
						if (value_inherit[e_value.METALLIC] != shader_uniform_metallic)
						{
							shader_uniform_metallic = value_inherit[e_value.METALLIC]
							render_set_uniform("uMetallic", shader_uniform_metallic)
						}
						
						if (value_inherit[e_value.EMISSIVE] != shader_uniform_emissive)
						{
							shader_uniform_emissive = value_inherit[e_value.EMISSIVE]
							render_set_uniform("uEmissive", shader_uniform_emissive)
						}
					}
				}
			}
		}
	}
	else
		render_world_block(scenery.block_vbuffer, res, true, scenery.scenery_size)
}
