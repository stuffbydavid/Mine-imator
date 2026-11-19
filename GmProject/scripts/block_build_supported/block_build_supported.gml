/// @desc Checks whether a neighboring block can support placement in the given direction.
/// @arg target
/// @arg position
/// @arg direction
/// @arg [sameblock]

function block_build_supported(target, blockpos, dir, sameblock = null)
{
	// Convert the builder direction to scenery block coordinates
	var offset, supportpos, supportdata, supportblock, supportface;
	offset = dir_get_vec3(dir)
	supportpos = vec3_add(blockpos, vec3(offset[Y], -offset[X], offset[Z]))
	supportdata = block_build_get_block(target, supportpos)

	// The support face points back toward the block being placed
	supportface = dir ^ 1
	
	// Use the clicked standalone block when starting a new structure
	if (target = null && !place_view_air && instance_exists(place_view_tl))
	{
		// Convert the world hit normal to the placement's local builder axes
		var inverse, hitnormal;
		inverse = matrix_inverse_ext(matrix_create(vec3(0), place_rot, place_sca))
		hitnormal = vec3_mul_matrix(place_view_world_normal, inverse)
		hitnormal = vec3(-hitnormal[Y], hitnormal[X], hitnormal[Z])
		
		if (supportface = vec3_get_dir(hitnormal))
		{
			// Read the block timeline owning the clicked model part
			var hittl = place_view_tl;
			if (hittl.type = e_tl_type.MODEL_PART && hittl.part_of != null)
				hittl = hittl.part_of
			
			var hitdata = null;
			with (hittl)
				hitdata = tl_get_block_build()
			
			if (hitdata != null)
				supportdata = hitdata
		}
	}
	
	// Missing blocks cannot provide support
	supportblock = block_objs[supportdata[0]]
	if (supportblock = null)
		return false
	
	// Allow a matching block to support a stack without a full face
	if (supportblock = sameblock)
		return true
	
	// Other blocks need render models describing their boundary faces
	if (supportblock.state_id_model_obj = null)
		return false

	// A state can use one model variant group or several multipart groups
	var modelvariants = supportblock.state_id_model_obj[supportdata[1]];
	if (!is_array(modelvariants))
		modelvariants = [ modelvariants ]
	
	// Check each model group belonging to the support block's state
	for (var i = 0; i < array_length(modelvariants); i++)
	{
		var modelvariant = modelvariants[i];
		if (is_undefined(modelvariant) || modelvariant = null)
			continue

		// Accept any model with a full support face at the cell boundary
		for (var m = 0; m < modelvariant.model_amount; m++)
		{
			var model = modelvariant.model[m];
			if (model.face_full[supportface])
				return true
		}
	}

	return false
}
