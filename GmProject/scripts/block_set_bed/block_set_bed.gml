/// block_set_bed()
/// @desc Returns an array with the head and foot models.

function block_set_bed()
{
	if (builder_scenery && !builder_scenery_legacy)
		return 0
	if (block_get_state_id_value(block_current, block_state_id_current, "part") = "foot")
		return null
	
	// Pick models
	var models = array(
		block_current.state_id_model_obj[block_state_id_current].model[0],
		block_current.state_id_model_obj[block_set_state_id_value(block_current, block_state_id_current, "part", "foot")].model[0]
	)
	
	var facing = block_get_state_id_value(block_current, block_state_id_current, "facing")
	if (facing = "north")
		models[1].offset_y = block_size
	else if (facing = "south")
		models[1].offset_y = -block_size
	else if (facing = "east")
		models[1].offset_x = -block_size
	else if (facing = "west")
		models[1].offset_x = block_size
	
	return array(models[0].rendermodel_id, models[1].rendermodel_id)
}
