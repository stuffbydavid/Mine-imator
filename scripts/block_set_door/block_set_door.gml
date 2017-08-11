/// block_set_door()
/// @desc Returns an array with the lower and upper door models, from their combined data.

if (is_undefined(vars[?"half"]) || vars[?"half"] = "upper")
	return null

// Fetch hinge value from upper half
if (!build_edge[e_dir.UP])
{
	var aboveblock = array3D_get(block_obj, point3D_add(build_pos, dir_get_vec3(e_dir.UP)));
	if (aboveblock = block_current)
	{
		var abovestate = array3D_get(block_state, point3D_add(build_pos, dir_get_vec3(e_dir.UP)));
		vars[?"hinge"] = block_vars_get_value(abovestate, "hinge")
	}
}
else
	vars[?"hinge"] = "left"

var models;
models[1] = 0

with (block_current.file)
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