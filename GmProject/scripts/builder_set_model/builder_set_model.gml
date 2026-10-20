/// @desc Sets the render model of the current block.
/// CppGen ArrRef build_pos
/// CppGen ArrRef build_size
/// CppGen ArrRef build_edge

function builder_set_model(ongeneration = false)
{
	// Read block coordinates once for this call
	var blockx, blocky, blockz, sizex, sizey, sizez;
	blockx = build_pos[X]
	blocky = build_pos[Y]
	blockz = build_pos[Z]
	sizex = build_size[X]
	sizey = build_size[Y]
	sizez = build_size[Z]
	
	block_current = builder_get_block(blockx, blocky, blockz)
	if (block_current = null)
		return 0
	
	block_state_id_current = builder_get_state_id(blockx, blocky, blockz)
	
	var model, ret;
	model = null
	ret = 0

	// Run a block-specific script that sets the state and returns 0,
	// or returns a render model/array of render models to use.
	if (block_current.set_script > -1)
	{
		if (!block_current.require_models || ongeneration)
		{
			build_edge[XP] = (blockx = sizex - 1)
			build_edge[XN] = (blockx = 0)
			build_edge[YP] = (blocky = sizey - 1)
			build_edge[YN] = (blocky = 0)
			build_edge[ZP] = (blockz = sizez - 1)
			build_edge[ZN] = (blockz = 0)
			
			ret = script_execute(block_current.set_script)
			if (ret != 0)
				model = ret
		}
		else
			ret = null
	}

	var tlvalid = (mc_builder.block_tl_add && block_current.timeline && block_tl_map != null && ret != null);
	
	if (tlvalid && mc_builder.block_tl_types != null)
		tlvalid = array_contains(mc_builder.block_tl_types, block_current.tl_type)
	
	if (tlvalid && block_current.tl_type = "sign")
		tlvalid = (!is_undefined(mc_builder.block_text_front_map[?build_pos_index]) || !is_undefined(mc_builder.block_text_back_map[?build_pos_index]))

	// Has timeline
	if (tlvalid && !block_current.model_double)
		block_tl_map[?build_pos_index] = [ block_current, block_state_id_current ]
	else
	{
		if (tlvalid && block_current.model_double)
			block_tl_map[?build_pos_index] = [ block_current, block_state_id_current ]
	
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
					model = []
					for (var i = 0; i < array_length(modelobj); i++)
						model[i] = block_get_render_model(modelobj[i], brightness, offset, offsetxy)
				}
				// Single model
				else 
					model = block_get_render_model(modelobj, brightness, offset, offsetxy)
			}
		}

		if (is_array(model))
			block_render_model_multipart_map[?build_pos_index] = model
		else if (model != null)
			builder_set_render_model(blockx, blocky, blockz, model)
	}
	
	return model
}
