/// @desc Returns an array with the lower and upper door models, from their combined data.

function block_set_door()
{
	if (build_get_connect)
		return block_set_tall_block()

	if (block_get_state_id_value(block_current, block_state_id_current, "half") = "upper")
		return null
	
	// Fetch hinge value from upper half
	var hinge, facing, open, location, dir;
	hinge = block_get_state_id_value(block_current, block_state_id_current, "hinge")
	facing = block_get_state_id_value(block_current, block_state_id_current, "facing")
	open = block_get_state_id_value(block_current, block_state_id_current, "open")
	
	if (!build_edge[ZP])
	{
		var aboveblock = builder_get_block(build_pos[X], build_pos[Y], build_pos[Z] + 1);
		if (aboveblock = block_current)
		{
			var abovestateid, abovefacing, opposite, reversed;
			abovestateid = builder_get_state_id(build_pos[X], build_pos[Y], build_pos[Z] + 1)
			abovefacing = block_get_state_id_value(block_current, abovestateid, "facing")
			hinge = block_get_state_id_value(block_current, abovestateid, "hinge")
			
			// Some legacy schematics store opposite facings in the upper halves
			opposite = facing
			switch (facing)
			{
				case "east": opposite = "west"; break
				case "west": opposite = "east"; break
				case "south": opposite = "north"; break
				case "north": opposite = "south"; break
			}
			reversed = (abovefacing = opposite)
			
			// Pre-1.2 doors repeat facing and open in the upper half instead of storing a hinge
			if (builder_scenery && builder_scenery_legacy &&
				block_get_state_id_value(block_current, abovestateid, "half") = "upper" &&
				block_get_state_id_value(block_current, abovestateid, "variant") = block_get_state_id_value(block_current, block_state_id_current, "variant") &&
				(abovefacing = facing || reversed))
			{
				if (block_get_state_id_value(block_current, abovestateid, "open") = "true")
				{
					// Some old schematics lost the lower open bit but retained it in the upper half
					hinge = "left"
					open = "true"
					block_state_id_current = block_set_state_id_value(block_current, block_state_id_current, "open", open)
				}
				else if (hinge = "right" && open = "false")
				{
					// Legacy double doors store different facing directions, whether open or closed
					var xx, yy, neighborfacing, neighborupperfacing;
					xx = build_pos[X]
					yy = build_pos[Y]
					
					switch (facing)
					{
						case "east":  yy++; neighborfacing = "north"; neighborupperfacing = "south"; break
						case "west":  yy--; neighborfacing = "south"; neighborupperfacing = "north"; break
						case "south": xx--; neighborfacing = "east";  neighborupperfacing = "west";  break
						case "north": xx++; neighborfacing = "west";  neighborupperfacing = "east";  break
					}
					
					if (!reversed)
						neighborupperfacing = neighborfacing
					
					if (xx >= 0 && yy >= 0 && xx < build_size[X] && yy < build_size[Y] &&
						builder_get_block(xx, yy, build_pos[Z]) = block_current &&
						builder_get_block(xx, yy, build_pos[Z] + 1) = block_current)
					{
						var lower, upper, variant;
						lower = builder_get_state_id(xx, yy, build_pos[Z])
						upper = builder_get_state_id(xx, yy, build_pos[Z] + 1)
						variant = block_get_state_id_value(block_current, block_state_id_current, "variant")
						
						if (block_get_state_id_value(block_current, lower, "half") = "lower" &&
							block_get_state_id_value(block_current, upper, "half") = "upper" &&
							block_get_state_id_value(block_current, lower, "variant") = variant &&
							block_get_state_id_value(block_current, upper, "variant") = variant &&
							block_get_state_id_value(block_current, lower, "facing") = neighborfacing &&
							block_get_state_id_value(block_current, upper, "facing") = neighborupperfacing)
						{
							// Reversed upper halves need an old upper open bit to distinguish modern hinges
							if (!reversed || block_get_state_id_value(block_current, upper, "open") = "true")
								hinge = "left"
						}
					}
				}
			}
		}
	}
	
	block_state_id_current = block_set_state_id_value(block_current, block_state_id_current, "hinge", hinge)
	
	// Set values for position/rotation
	if (facing = "east")
	{
		location = (hinge = "right" ? "south_west" : "north_west")
		if (open = "false")
			dir = (hinge = "right" ? "north" : "south")
	}
	else if (facing = "west")
	{
		location = (hinge = "right" ? "north_east" : "south_east")
		if (open = "false")
			dir = (hinge = "right" ? "south" : "north")
	}
	else if (facing = "south")
	{
		location = (hinge = "right" ? "north_west" : "north_east")
		if (open = "false")
			dir = (hinge = "right" ? "east" : "west")
	}
	else if (facing = "north")
	{
		location = (hinge = "right" ? "south_east" : "south_west")
		if (open = "false")
			dir = (hinge = "right" ? "west" : "east")
	}
	
	if (open = "true")
		dir = facing
		
	// Reset timeline positioning states before selecting block models
	block_state_id_current = block_set_state_id_value(block_current, block_state_id_current, "location", "north_west")
	block_state_id_current = block_set_state_id_value(block_current, block_state_id_current, "direction", "north")

	var bottommodel, topmodel;
	bottommodel = block_current.state_id_model_obj[block_state_id_current]
	topmodel = block_current.state_id_model_obj[block_set_state_id_value(block_current, block_state_id_current, "half", "upper")]
	if (is_undefined(bottommodel) || is_undefined(topmodel))
		return null
	
	// Pick models
	bottommodel = bottommodel.model[0]
	topmodel = topmodel.model[0]

	bottommodel.offset[Z] = 0
	topmodel.offset[Z] = block_size

	block_state_id_current = block_set_state_id_value(block_current, block_state_id_current, "location", location)
	block_state_id_current = block_set_state_id_value(block_current, block_state_id_current, "direction", dir)
	
	return [ bottommodel.rendermodel_id, topmodel.rendermodel_id ]
}
