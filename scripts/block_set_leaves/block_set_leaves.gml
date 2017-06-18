/// block_set_leaves()
/// @desc Returns the opaque or transparent model.

var block = mc_version.block_map[?block_id_current];

with (block.data_states[block_data_current])
{
	if (variant_amount = 0)
		break
		
	with (variant[0])
	{
		if (model_amount = 0)
			break
			
		if (app.background_opaque_leaves)
			return array(model_opaque[0])
		else
			return array(model[0])
	}
}

return null