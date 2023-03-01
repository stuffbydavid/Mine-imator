/// builder_set_model([ongeneration])
/// @arg [ongeneration]
/// @desc Sets the render model of the current block.
function builder_set_model(ongeneration = false)
{
	block_current = builder_get_block(build_pos_x, build_pos_y, build_pos_z)
	if (block_current = null)
		return 0
	block_state_id_current = builder_get_state_id(build_pos_x, build_pos_y, build_pos_z)
	
	var model, ret;
	model = null
	ret = 0

	// Run a block-specific script that sets the state and returns 0,
	// or returns a render model/array of render models to use.
	if (block_current.set_script > -1)
	{
		if (!block_current.require_models || ongeneration)
		{
			build_edge_xp = (build_pos_x = build_size_x - 1)
			build_edge_xn = (build_pos_x = 0)
			build_edge_yp = (build_pos_y = build_size_y - 1)
			build_edge_yn = (build_pos_y = 0)
			build_edge_zp = (build_pos_z = build_size_z - 1)
			build_edge_zn = (build_pos_z = 0)
			ret = script_execute(block_current.set_script);
			if (ret != 0)
				model = ret
		}
		else
			ret = null
	}

	var tlvalid = (mc_builder.block_tl_add = null || mc_builder.block_tl_add) && block_current.timeline && block_tl_map != null && ret != null;

	// Has timeline
	if (tlvalid && !block_current.model_double)
		block_tl_map[?build_pos] = array(block_current, block_state_id_current)
	else
	{
		if (tlvalid && block_current.model_double)
			block_tl_map[?build_pos] = array(block_current, block_state_id_current)
	
		// Look for the render model of the current state
		if (ret = 0 && block_current.state_id_model_obj != null)
		{
			var modelobj = block_current.state_id_model_obj[block_state_id_current];
			if (modelobj != null && !is_undefined(modelobj))
			{
				var brightness, offset, offsetxy;
				brightness = block_current.state_id_emissive[block_state_id_current]
				offset = block_current.state_id_random_offset[block_state_id_current]
				offsetxy = block_current.state_id_random_offset_xy[block_state_id_current]
			
				// Multipart
				if (is_array(modelobj))
				{
					model = array()
					for (var i = 0; i < array_length(modelobj); i++)
						array_add(model, block_get_render_model(modelobj[i], brightness, offset, offsetxy))
				}
				// Single model
				else 
					model = block_get_render_model(modelobj, brightness, offset, offsetxy)
			}
		}

		if (is_array(model))
			block_render_model_multipart_map[?build_pos] = model
		else if (model != null)
			builder_set_render_model(build_pos_x, build_pos_y, build_pos_z, model)
	}
	
	return model
}
