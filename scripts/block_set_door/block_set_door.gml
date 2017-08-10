/// block_set_door()
/// @desc Returns an array with the lower and upper door models, from their combined data.

if (is_undefined(vars[?"half"]) || vars[?"half"] = "upper")
	return null

// Fetch hinge value from upper half
if (!build_edge[e_dir.UP])
{
	var aboveid, abovedata, aboveblock;
	aboveid = array3D_get(block_id, point3D_add(build_pos, dir_get_vec3(e_dir.UP)))
	abovedata = array3D_get(block_data, point3D_add(build_pos, dir_get_vec3(e_dir.UP)))
	aboveblock = mc_version.block_map[?aboveid]
	
	if (!is_undefined(aboveblock))
	{
		var abovedatavars = aboveblock.data_vars[abovedata];
		vars[?"hinge"] = abovedatavars[?"hinge"]
	}
}
else
	vars[?"hinge"] = "left"

var models, block;
models[1] = 0
block = mc_version.block_map[?block_id_current]
with (block.data_states[block_data_current])
{
	// Set lower model
	for (var v = 0; v < variant_amount; v++)
	{
		with (variant[v])
		{
			if (model_amount = 0 || !block_vars_match(vars, mc_builder.vars))
				break
			
			models[0] = model[0]
			break
		}
		
		if (models[0])
			break
	}
	
	// Set upper model
	mc_builder.vars[?"half"] = "upper"
	for (var v = 0; v < variant_amount; v++)
	{
		with (variant[v])
		{
			if (model_amount = 0 || !block_vars_match(vars, mc_builder.vars))
				break
			
			model[0].offset[Z] = block_size
			models[1] = model[0]
			break
		}
		
		if (models[1])
			break
	}
}

return models