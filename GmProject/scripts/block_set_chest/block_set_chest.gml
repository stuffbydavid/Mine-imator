/// @desc Finds double chests.

function block_set_chest()
{
	var type, double;
	type = block_get_state_id_value(block_current, block_state_id_current, "type")
	double = "false"
	
	switch (type)
	{
		case "single":	break
		case "right":	double = "true"; break
		case "left":	return null
		case "legacy":
		{
			if (block_current.name = "ender_chest")
				break
				
			// Determine type from adjacent chest
			var connectblock, discardblock;
			connectblock = null
			discardblock = null
			
			var facing = block_get_state_id_value(block_current, block_state_id_current, "facing");
			switch (facing)
			{
				case "east":
				{
					if (!build_edge[YN])
						connectblock = builder_get_block(build_pos[X], build_pos[Y] - 1, build_pos[Z])
					
					if (!build_edge[YP])
						discardblock = builder_get_block(build_pos[X], build_pos[Y] + 1, build_pos[Z])
					
					break
				}
				
				case "west":
				{
					if (!build_edge[YP])
						connectblock = builder_get_block(build_pos[X], build_pos[Y] + 1, build_pos[Z])
					
					if (!build_edge[YN])
						discardblock = builder_get_block(build_pos[X], build_pos[Y] - 1, build_pos[Z])
					
					break
				}
				
				case "south":
				{
					if (!build_edge[XP])
						connectblock = builder_get_block(build_pos[X] + 1, build_pos[Y], build_pos[Z])
					
					if (!build_edge[XN])
						discardblock = builder_get_block(build_pos[X] - 1, build_pos[Y], build_pos[Z])
					
					break
				}
				
				case "north":
				{
					if (!build_edge[XN])
						connectblock = builder_get_block(build_pos[X] - 1, build_pos[Y], build_pos[Z])
					
					if (!build_edge[XP])
						discardblock = builder_get_block(build_pos[X] + 1, build_pos[Y], build_pos[Z])
					
					break
				}
			}
			
			if (discardblock = block_current) // Discard
				return null
			
			if (connectblock = block_current) // Connect
				double = "true"
			else
				double = "false"
		}
	}
	
	block_state_id_current = block_set_state_id_value(block_current, block_state_id_current, "double", double)
	
	return 0
}
