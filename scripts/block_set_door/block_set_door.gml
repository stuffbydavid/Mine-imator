/// block_set_door()
/// @desc Returns an array with the lower and upper door models, from their combined data.
/*
if (state_vars_get_value(vars, "half") = "upper")
	return null

// Fetch hinge value from upper half
if (!build_edge[e_dir.UP])
{
	var aboveblock = array3D_get(block_obj, build_size, point3D_add(build_pos, dir_get_vec3(e_dir.UP)));
	if (aboveblock = block_current)
	{
		var abovestate = array3D_get(block_state, build_size, point3D_add(build_pos, dir_get_vec3(e_dir.UP)));
		state_vars_set_value(vars, "hinge", state_vars_get_value(abovestate, "hinge"))
	}
}

var models = array(null, null);

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
	state_vars_set_value(mc_builder.vars, "half", "upper")
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
var hingeright = (state_vars_get_value(vars, "hinge") = "right");
var open = (state_vars_get_value(vars, "open") = "true");

switch (string_to_dir(state_vars_get_value(vars, "facing")))
{
	case e_dir.EAST:
	{
		state_vars_set_value(vars, "location", test(hingeright, "south_west", "north_west"))
		if (!open)
			state_vars_set_value(vars, "direction", test(hingeright, "north", "south"))
		break
	}
	
	case e_dir.WEST:
	{
		state_vars_set_value(vars, "location", test(hingeright, "north_east", "south_east"))
		if (!open)
			state_vars_set_value(vars, "direction", test(hingeright, "south", "north"))
		break
	}
	
	case e_dir.SOUTH:
	{
		state_vars_set_value(vars, "location", test(hingeright, "north_west", "north_east"))
		if (!open)
			state_vars_set_value(vars, "direction", test(hingeright, "east", "west"))
		break
	}
	
	case e_dir.NORTH:
	{
		state_vars_set_value(vars, "location", test(hingeright, "south_east", "south_west"))
		if (!open)
			state_vars_set_value(vars, "direction", test(hingeright, "west", "east"))
		break
	}
}

if (open)
	state_vars_set_value(vars, "direction", state_vars_get_value(vars, "facing"))

return models*/