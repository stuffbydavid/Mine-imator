/// tl_update_bounding_box()

function tl_update_bounding_box()
{
	// No 3D representation
	if (type = e_tl_type.CHARACTER ||
		type = e_tl_type.SPECIAL_BLOCK ||
		type = e_tl_type.FOLDER ||
		type = e_tl_type.BACKGROUND ||
		type = e_tl_type.AUDIO ||
		type = e_tl_type.PARTICLE_SPAWNER ||
		type = e_tl_type.SPOT_LIGHT ||
		type = e_tl_type.POINT_LIGHT ||
		type = e_tl_type.CAMERA)
		return 0
	
	// Shapes
	if (type = e_tl_type.BLOCK || type = e_tl_type.CUBE || type = e_tl_type.CONE ||
		type = e_tl_type.CYLINDER || type = e_tl_type.SPHERE || type = e_tl_type.SURFACE)
		bounding_box.copy(temp.bounding_box)
	
	if (type = e_tl_type.ITEM && !value[e_value.CUSTOM_ITEM_SLOT])
		bounding_box.copy(temp.bounding_box)
	
	if (temp.scenery != null && type = e_tl_type.SCENERY)
		bounding_box.copy(temp.scenery.bounding_box)
	
	if (type = e_tl_type.BLOCK || type = e_tl_type.SCENERY)
	{
		var size, rotmat, reppos, rep, repbox, repgroupbox;
		size = 1
		rep = temp.block_repeat
		repbox = new bbox()
		repgroupbox = new bbox()
		
		if (type = e_tl_type.BLOCK)
			size = temp.block_repeat_enable ? temp.block_repeat : vec3(1)
		else
			size = temp.scenery.scenery_size
		
		rotmat = matrix_create(point3D(0, size[Y] * block_size, 0), vec3(0, 0, 90), vec3(1))
		
		if (temp.block_repeat_enable && type = e_tl_type.SCENERY)
		{
			for (reppos[X] = 0; reppos[X] < rep[X]; reppos[X]++)
			{
				for (reppos[Y] = 0; reppos[Y] < rep[Y]; reppos[Y]++)
				{
					for (reppos[Z] = 0; reppos[Z] < rep[Z]; reppos[Z]++)
					{
						var pos = vec3_mul(temp.scenery.scenery_size, point3D_mul(reppos, block_size));
						
						repbox.copy(bounding_box)
						repbox.mul_matrix(matrix_multiply(rotmat, matrix_create(pos, vec3(0), vec3(1))))
						
						repgroupbox.merge(repbox)
					}
				}
			}
			
			bounding_box.copy(repgroupbox)
		}
		else
			bounding_box.mul_matrix(rotmat)
	}
	
	bounding_box_matrix.copy(bounding_box)
	bounding_box_matrix.mul_matrix(matrix_render)
}