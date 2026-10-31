/// @desc Returns an array with the upper and lower plant models.

function block_set_double_plant()
{
	if (build_get_connect)
		return block_set_tall_block()

	if (block_get_state_id_value(block_current, block_state_id_current, "half") = "upper")
		return null
	
	// Pick models
	var bottommodel, topmodel;
	bottommodel = block_current.state_id_model_obj[block_state_id_current].model[0]
	topmodel = block_current.state_id_model_obj[block_set_state_id_value(block_current, block_state_id_current, "half", "upper")].model[0]
	
	topmodel.offset[Z] = block_size
	
	return [ bottommodel.rendermodel_id, topmodel.rendermodel_id ]
}
