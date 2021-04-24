/// builder_set_model([ongeneration])
/// @arg [ongeneration]
/// @desc Sets the render model of the current block.

function builder_set_model()
{
	block_current = builder_get(block_obj, build_pos_x, build_pos_y, build_pos_z)
	if (block_current = null)
		return 0
	
	block_state_id_current = builder_get(block_state_id, build_pos_x, build_pos_y, build_pos_z)
	
	var model, ret;
	model = null
	ret = 0
	
	// Run a block-specific script that sets the state and returns 0,
	// or returns a render model/array of render models to use.
	if (block_current.set_script > -1)
	{
		if (!block_current.require_models || (argument_count > 0  && argument[0]))
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
	
	var tlvalid = (block_tl_add = null || block_tl_add) && block_current.timeline && block_tl_list != null && ret != null;
	
	// Has timeline
	if (tlvalid && !block_current.model_double)
		ds_list_add(block_tl_list, block_get_timeline(block_current, block_state_id_current))
	else
	{
		if (tlvalid && block_current.model_double)
			ds_list_add(block_tl_list, block_get_timeline(block_current, block_state_id_current))
		
		// Look for the render model of the current state
		if (ret = 0 && block_current.state_id_model_obj != null)
		{
			var modelobj = block_current.state_id_model_obj[block_state_id_current];
			if (modelobj != null && !is_undefined(modelobj))
			{
				var brightness = block_current.state_id_brightness[block_state_id_current];
				
				// Multipart
				if (is_array(modelobj))
				{
					model = array()
					for (var i = 0; i < array_length(modelobj); i++)
						array_add(model, block_get_render_model(modelobj[i], brightness))
				}
				// Single model
				else 
					model = block_get_render_model(modelobj, brightness)
			}
		}
		
		// Set model
		if (model != null)
			builder_set_render_model(build_pos_x, build_pos_y, build_pos_z, model)
	}
}
