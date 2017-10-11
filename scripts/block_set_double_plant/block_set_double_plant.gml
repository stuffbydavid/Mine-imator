/// block_set_double_plant()
/// @desc Returns an array with the upper and lower plant models.

if (block_get_state_id_value(block_current, block_state_id_current, "half") = "upper")
	return null
	
// Pick models
var models = array(
	block_current.state_id_variant[block_state_id_current].model[0],
	block_current.state_id_variant[block_set_state_id_value(block_current, block_state_id_current, "half", "upper")].model[0]
)

models[1].offset_z = block_size

return models