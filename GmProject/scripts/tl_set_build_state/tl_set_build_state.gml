/// @desc Updates a block timeline's state and preserves its placement transform.
/// @arg block
/// @arg stateid

function tl_set_build_state(block, stateid)
{
	if (block.type = "door")
		stateid = block_get_door_state(block, stateid)

	// Update the shared template, or the timeline's own model settings
	var source, prevstate;
	source = temp
	prevstate = block_get_state_id(block, block_build_state)
	
	with (source)
	{
		// Block template or timeline
		if (type = e_temp_type.BLOCK)
		{
			block_name = block.name
			block_state = block_get_state_id_state_vars(block, stateid)

			if (block.timeline)
			{
				block_state = block_get_timeline_render_state(block, stateid)
				block_transform = block.tl_build_transform
			}

			if (object_index = obj_timeline)
				tl_update_scenery_part()
			else
				temp_update_block()
		}
		
		// Special block template or timeline
		else if (block.timeline)
		{
			var newstate = block_get_timeline_model_state(block, stateid);
			if (!array_equals(model_state, newstate))
			{
				model_state = newstate
				
				temp_update_model()
				temp_update_model_timeline_tree()
				temp_update_model_shape()
			}
		}

		temp_update_display_name()
	}

	// Keep each rendered copy's placement when applying the shared state
	with (obj_timeline)
	{
		if (temp != source || (type != e_tl_type.BLOCK && type != e_tl_type.SPECIAL_BLOCK))
			continue

		if (block.timeline)
		{
			var oldtransform, worldtransform;
			oldtransform = block_get_timeline_matrix(block, prevstate)
			worldtransform = matrix
			
			if (block_build_name != "")
				oldtransform = block_get_timeline_matrix(block, block_get_state_id(block, block_build_state))

			rot_point_custom = true
			rot_point = block_get_timeline_rot_point(block, stateid)
			
			tl_update_rot_point()

			// Apply the state transform relative to this copy's current placement
			var transform = block_get_timeline_matrix(block, stateid);
			tl_value_set_matrix(id, matrix_multiply(matrix_multiply(transform, matrix_inverse_ext(oldtransform)), worldtransform))
			if (type = e_tl_type.SPECIAL_BLOCK)
				tl_apply_block_parts(block, stateid)
		}

		block_build_name = block.name
		block_build_state = block_get_state_id_state_vars(block, stateid)
		
		tl_update_build_block()
		
		update_matrix = true
	}
}
