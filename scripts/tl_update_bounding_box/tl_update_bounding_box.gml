/// tl_update_bounding_box()

function model_update_bounding_box(root, box)
{
	for (var i = 0; i < ds_list_size(root.tree_list); i++)
	{
		var c = root.tree_list[|i];
			
		if (c.part_of = null)
			continue
		else
		{
			box.merge(c.bounding_box_matrix)
			model_update_bounding_box(c, box)
		}
	}
}

function tl_update_bounding_box()
{
	// No 3D representation
	if (type = e_tl_type.FOLDER ||
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
	
	// Block model
	if (type = e_tl_type.MODEL && temp.model != null && temp.model.model_format = e_model_format.BLOCK)
		bounding_box.copy(temp.model.bounding_box)
	
	// Scenery objects(?)
	if (temp = null)
		return 0
	
	if (temp.scenery != null && type = e_tl_type.SCENERY)
		bounding_box.copy(temp.scenery.bounding_box)
	
	// Calculate block/scenery repeat
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
			var oldsize = [array_length(scenery_repeat_bounding_box),
						   array_length(scenery_repeat_bounding_box[0]),
						   array_length(scenery_repeat_bounding_box[0][0])];
			
			for (reppos[X] = 0; reppos[X] < oldsize[X]; reppos[X]++)
			{
				for (reppos[Y] = 0; reppos[Y] < oldsize[Y]; reppos[Y]++)
				{
					for (reppos[Z] = 0; reppos[Z] < oldsize[Z]; reppos[Z]++)
					{
						var repindex = scenery_repeat_bounding_box[reppos[X]][reppos[Y]][reppos[Z]];
						
						var repindexsize = [array_length(repindex), array_length(repindex[0]), array_length(repindex[0][0])];
						  
						for (var cx = 0; cx < repindexsize[X]; cx++)
							for (var cy = 0; cy < repindexsize[Y]; cy++)
								for (var cz = 0; cz < repindexsize[Z]; cz++)
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
						
						var size = [array_length(temp.scenery.scenery_chunk_array),
									array_length(temp.scenery.scenery_chunk_array[0]),
									array_length(temp.scenery.scenery_chunk_array[0][0])]
						
						// Create chunk bounding boxes
						for (var cx = 0; cx < size[X]; cx++)
						{
							for (var cy = 0; cy < size[Y]; cy++)
							{
								for (var cz = 0; cz < size[Z]; cz++)
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
			var chunkssize = [array_length(chunks), array_length(chunks[0]), array_length(chunks[0][0])];
			
			// Create chunk bounding boxes
			for (var cx = 0; cx < chunkssize[X]; cx++)
			{
				for (var cy = 0; cy < chunkssize[Y]; cy++)
				{
					for (var cz = 0; cz < chunkssize[Z]; cz++)
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
	
	// Calculate bounding box covering entire model
	if (type = e_tl_type.CHARACTER ||
		type = e_tl_type.SPECIAL_BLOCK ||
		(type = e_tl_type.MODEL && temp.model.model_format = e_model_format.MIMODEL))
	{
		bounding_box.reset()
		model_update_bounding_box(id, bounding_box)
		bounding_box_matrix.copy(bounding_box)
		return 0
	}
	
	bounding_box_matrix.copy(bounding_box)
	bounding_box_matrix.mul_matrix(matrix_render)
}