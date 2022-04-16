/// tl_update_bounding_box()

function model_update_bounding_box(modelroot, root, box)
{
	for (var i = 0; i < ds_list_size(root.tree_list); i++)
	{
		with (root.tree_list[|i])
		{
			if (render_visible && ((value_inherit[e_value.ALPHA] * 1000) != 0))
			{
				ds_list_add(modelroot.model_timeline_list, id)
				box.merge(bounding_box_matrix)
			}
		
			model_update_bounding_box(modelroot, id, box)
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
	
	// No template (Scenery objects/paths?)
	if (temp = null && type != e_tl_type.PATH)
		return 0
	
	// Not visible
	if (!value_inherit[e_value.VISIBLE] || hide)
		return 0
	
	// Calculate block/scenery repeat
	if (type = e_tl_type.BLOCK || type = e_tl_type.SCENERY)
	{
		var size, rotmat, reppos, rep, repbox, repgroupbox;
		size = vec3(0)
		rep = temp.block_repeat
		repbox = new bbox()
		repgroupbox = new bbox()
		
		if (type = e_tl_type.BLOCK)
			size = temp.block_repeat_enable ? temp.block_repeat : vec3(1)
		else
			size = (temp.scenery != null ? temp.scenery.scenery_size: vec3(0))
		
		// Not ready
		if (type = e_tl_type.SCENERY && temp.scenery != null && temp.scenery.block_vbuffer = null)
			return 0
		
		rotmat = matrix_create(point3D(0, size[Y] * block_size, 0), vec3(0, 0, 90), vec3(1))
		
		// No scenery resource
		if (type = e_tl_type.SCENERY && temp.scenery = null)
			return 0
		
		if (type = e_tl_type.SCENERY)
			bounding_box.copy(temp.scenery.bounding_box)
		
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
					}
				}
			}
			
			bounding_box.copy(repgroupbox)
			
			delete repgroupbox
			delete repbox
		}
		else // Not repeat
			bounding_box.mul_matrix(rotmat)
	}
	
	// Calculate bounding box covering entire model
	/*
	if (type = e_tl_type.CHARACTER ||
		type = e_tl_type.SPECIAL_BLOCK ||
		(type = e_tl_type.MODEL && temp.model.model_format = e_model_format.MIMODEL))
	{
		bounding_box.reset()
		
		if (model_timeline_list = null)
			model_timeline_list = ds_list_create()
		else
			ds_list_clear(model_timeline_list)
		
		model_update_bounding_box(id, id, bounding_box)
		bounding_box_matrix.copy(bounding_box)
		return 0
	}
	*/
	
	bounding_box_matrix.copy(bounding_box)
	bounding_box_matrix.mul_matrix(matrix_render)
}