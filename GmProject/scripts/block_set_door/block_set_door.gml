/// block_set_door()
/// @desc Returns an array with the lower and upper door models, from their combined data.

function block_set_door()
{
	if (block_get_state_id_value(block_current, block_state_id_current, "half") = "upper")
		return null
	
	// Fetch hinge value from upper half
	var hinge = block_get_state_id_value(block_current, block_state_id_current, "hinge");
	if (!build_edge_zp)
	{
		var aboveblock = builder_get_block(build_pos_x, build_pos_y, build_pos_z + 1);
		if (aboveblock = block_current)
		{
			var abovestateid = builder_get_state_id(build_pos_x, build_pos_y, build_pos_z + 1);
			hinge = block_get_state_id_value(block_current, abovestateid, "hinge")
			block_state_id_current = block_set_state_id_value(block_current, block_state_id_current, "hinge", hinge)
		}
	}
	
	// Set values for position/rotation
	var facing, open, location, dir;
	facing = block_get_state_id_value(block_current, block_state_id_current, "facing")
	open = block_get_state_id_value(block_current, block_state_id_current, "open")
	
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
		
	var bottommodel = block_current.state_id_model_obj[block_state_id_current];
	var topmodel = block_current.state_id_model_obj[block_set_state_id_value(block_current, block_state_id_current, "half", "upper")];
	if (is_undefined(bottommodel) || is_undefined(topmodel))
		return null
	
	// Pick models
	var models = array(
		bottommodel.model[0],
		topmodel.model[0]
	)

	models[1].offset_z = block_size

	block_state_id_current = block_set_state_id_value(block_current, block_state_id_current, "location", location)
	block_state_id_current = block_set_state_id_value(block_current, block_state_id_current, "direction", dir)
	
	return array(models[0].rendermodel_id, models[1].rendermodel_id)
}
