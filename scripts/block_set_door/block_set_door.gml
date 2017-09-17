/// block_set_door()
/// @desc Returns an array with the lower and upper door models, from their combined data.

if (vars[?"half"] = "upper")
	return null

// Fetch hinge value from upper half
if (!build_edge[e_dir.UP])
{
	var aboveblock = array3D_get(block_obj, point3D_add(build_pos, dir_get_vec3(e_dir.UP)));
	if (aboveblock = block_current)
	{
		var abovestate = array3D_get(block_state, point3D_add(build_pos, dir_get_vec3(e_dir.UP)));
		vars[?"hinge"] = state_vars_get_value(abovestate, "hinge")
	}
}

var models;
models[1] = 0

with (block_current.file)
{
	// Set lower model
	for (var v = 0; v < variant_amount; v++)
	{
		with (variant[v])
		{
			if (model_amount = 0 || !state_vars_match(vars, mc_builder.vars))
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
			if (model_amount = 0 || !state_vars_match(vars, mc_builder.vars))
				break
			
			model[0].offset[Z] = block_size
			models[1] = model[0]
			break
		}
		
		if (models[1])
			break
	}
}

// Set values for position/rotation
switch (string_to_dir(vars[?"facing"]))
{
	case e_dir.EAST:
	{
		vars[?"location"] = test(vars[?"hinge"] = "right", "south_west", "north_west")
		if (vars[?"open"] = "false")
			vars[?"direction"] = test(vars[?"hinge"] = "right", "north", "south")
		break
	}
	
	case e_dir.WEST:
	{
		vars[?"location"] = test(vars[?"hinge"] = "right", "north_east", "south_east")
		if (vars[?"open"] = "false")
			vars[?"direction"] = test(vars[?"hinge"] = "right", "south", "north")
		break
	}
	
	case e_dir.SOUTH:
	{
		vars[?"location"] = test(vars[?"hinge"] = "right", "north_west", "north_east")
		if (vars[?"open"] = "false")
			vars[?"direction"] = test(vars[?"hinge"] = "right", "east", "west")
		break
	}
	
	case e_dir.NORTH:
	{
		vars[?"location"] = test(vars[?"hinge"] = "right", "south_east", "south_west")
		if (vars[?"open"] = "false")
			vars[?"direction"] = test(vars[?"hinge"] = "right", "west", "east")
		break
	}
}

if (vars[?"open"] = "true")
	vars[?"direction"] = vars[?"facing"]

return models