/// @desc Returns an array with the head and foot models.

function block_set_bed()
{
	if (builder_scenery && !builder_scenery_legacy)
		return 0
	
	if (block_get_state_id_value(block_current, block_state_id_current, "part") = "foot")
		return null
	
	// Pick models
	var headmodel, footmodel;
	headmodel = block_current.state_id_model_obj[block_state_id_current].model[0]
	footmodel = block_current.state_id_model_obj[block_set_state_id_value(block_current, block_state_id_current, "part", "foot")].model[0]
	
	var facing = block_get_state_id_value(block_current, block_state_id_current, "facing");
	if (facing = "north")
		footmodel.offset[Y] = block_size
	else if (facing = "south")
		footmodel.offset[Y] = -block_size
	else if (facing = "east")
		footmodel.offset[X] = -block_size
	else if (facing = "west")
		footmodel.offset[X] = block_size
	
	return [ headmodel.rendermodel_id, footmodel.rendermodel_id ]
}
