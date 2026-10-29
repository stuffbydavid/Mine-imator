/// @arg scenery
/// @arg diffuse
/// @arg normal
/// @arg material
/// @arg repeatenable
/// @arg repeat

function render_world_scenery(scenery, resdif, resnorm, resmat, repeatenable, rep)
{
	if (!scenery.ready)
		return 0

	var meshobj, meshcount;
	meshobj = scenery
	meshcount = array_length(scenery.block_meshes)
	if (object_index = obj_timeline && type = e_tl_type.SCENERY && array_length(block_meshes_edit) > 0)
	{
		meshobj = id
		meshcount = block_meshes_num[X] * block_meshes_num[Y] * block_meshes_num[Z]
	}
	
	if (!repeatenable)
		render_world_block_meshes(meshobj, resdif, resnorm, resmat, 0, meshcount)
	
	else // Repeat
	{
		var mat, reppos, defrot, defscale;
		mat = matrix_get(matrix_world)
		reppos = [ 0, 0, 0 ]
		defrot = [ 0, 0, 0 ]
		defscale = [ 1, 1, 1 ]
		
		for (reppos[X] = 0; reppos[X] < rep[X]; reppos[X]++)
		for (reppos[Y] = 0; reppos[Y] < rep[Y]; reppos[Y]++)
		for (reppos[Z] = 0; reppos[Z] < rep[Z]; reppos[Z]++)
		{
			var pos = vec3_mul(scenery.scenery_size, point3D_mul(reppos, block_size));
			matrix_set(matrix_world, matrix_multiply(matrix_create(pos, defrot, defscale), mat))
			
			var offset = 0;
			if (meshobj != scenery)
				offset = ((reppos[Z] * rep[Y] + reppos[Y]) * rep[X] + reppos[X]) * meshcount
			
			render_world_block_meshes(meshobj, resdif, resnorm, resmat, offset, meshcount)

			if (self.object_index != obj_preview && !render_fast_pass)
			{
				if (value_inherit[e_value.ROUGHNESS] != shader_uniform_roughness)
				{
					shader_uniform_roughness = value_inherit[e_value.ROUGHNESS]
					render_set_uniform(e_uniform.ROUGHNESS, shader_uniform_roughness)
				}

				if (value_inherit[e_value.METALLIC] != shader_uniform_metallic)
				{
					shader_uniform_metallic = value_inherit[e_value.METALLIC]
					render_set_uniform(e_uniform.METALLIC, shader_uniform_metallic)
				}

				if (value_inherit[e_value.EMISSIVE] != shader_uniform_emissive)
				{
					shader_uniform_emissive = value_inherit[e_value.EMISSIVE]
					render_set_uniform(e_uniform.EMISSIVE, shader_uniform_emissive)
				}
			}
		}
	}
}
