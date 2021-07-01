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
		
		// Delete old chunk bounding boxes
		if (scenery_repeat_bounding_box != null)
		{
			for (reppos[X] = 0; reppos[X] < array_length(scenery_repeat_bounding_box); reppos[X]++)
			{
				for (reppos[Y] = 0; reppos[Y] < array_length(scenery_repeat_bounding_box[0]); reppos[Y]++)
				{
					for (reppos[Z] = 0; reppos[Z] < array_length(scenery_repeat_bounding_box[0][0]); reppos[Z]++)
					{
						var repindex = scenery_repeat_bounding_box[reppos[X]][reppos[Y]][reppos[Z]];
							
						for (var cx = 0; cx < array_length(repindex); cx++)
							for (var cy = 0; cy < array_length(repindex[0]); cy++)
								for (var cz = 0; cz < array_length(repindex[0][0]); cz++)
									delete repindex[cx][cy][cz]
					}
				}
			}
				
			scenery_repeat_bounding_box = null
		}
		
		if (temp.block_repeat_enable && type = e_tl_type.SCENERY)
		{
			for (reppos[X] = 0; reppos[X] < rep[X]; reppos[X]++)
			{
				for (reppos[Y] = 0; reppos[Y] < rep[Y]; reppos[Y]++)
				{
					for (reppos[Z] = 0; reppos[Z] < rep[Z]; reppos[Z]++)
					{
						// Grouped bounding box
						var pos = vec3_mul(temp.scenery.scenery_size, point3D_mul(reppos, block_size));
						
						repbox.copy(bounding_box)
						repbox.mul_matrix(matrix_multiply(rotmat, matrix_create(pos, vec3(0), vec3(1))))
						
						repgroupbox.merge(repbox)
						
						// Create chunk bounding boxes
						for (var cx = 0; cx < array_length(temp.scenery.scenery_chunk_array); cx++)
						{
							for (var cy = 0; cy < array_length(temp.scenery.scenery_chunk_array[0]); cy++)
							{
								for (var cz = 0; cz < array_length(temp.scenery.scenery_chunk_array[0][0]); cz++)
								{
									var box;
									box = new bbox()
									
									box.copy(temp.scenery.scenery_chunk_array[cx][cy][cz].bounding_box)
									box.mul_matrix(matrix_multiply(rotmat, matrix_create(pos, vec3(0), vec3(1))))
									box.mul_matrix(matrix_render)
									
									scenery_repeat_bounding_box[reppos[X]][reppos[Y]][reppos[Z]][cx][cy][cz] = box
								}
							}
						}
					}
				}
			}
			
			bounding_box.copy(repgroupbox)
		}
		else
		{
			bounding_box.mul_matrix(rotmat)
			
			var chunks = (temp.type = e_temp_type.SCENERY ? temp.scenery.scenery_chunk_array : temp.scenery_chunk_array);
			
			// Create chunk bounding boxes
			for (var cx = 0; cx < array_length(chunks); cx++)
			{
				for (var cy = 0; cy < array_length(chunks[0]); cy++)
				{
					for (var cz = 0; cz < array_length(chunks[0][0]); cz++)
					{
						var box = new bbox();
						
						box.copy(chunks[cx][cy][cz].bounding_box)
						box.mul_matrix(rotmat)
						box.mul_matrix(matrix_render)
						
						scenery_repeat_bounding_box[0][0][0][cx][cy][cz] = box
					}
				}
			}
		}
	}
	
	bounding_box_matrix.copy(bounding_box)
	bounding_box_matrix.mul_matrix(matrix_render)
}