/// @desc Resolves dripleaf stems and renders standalone two-part plants.

function block_set_big_dripleaf()
{
	var modelvariant = block_current.state_id_model_obj[block_state_id_current];
	if (is_undefined(modelvariant) || modelvariant = null || modelvariant.model_amount = 0)
		return 0

	// Clear the upper offset used by a standalone two-part plant
	var model = modelvariant.model[0];
	model.offset[Z] = 0

	if ((builder_scenery && !builder_scenery_legacy) || block_get_state_id_value(block_current, block_state_id_current, "type") = "big_dripleaf_stem")
		return 0

	// Standalone block timelines render the stem and upper leaf together
	if (!builder_scenery && !build_edit && build_size[Z] = 1)
	{
		var stemstate, stemmodel;
		stemstate = block_set_state_id_value(block_current, block_state_id_current, "type", "big_dripleaf_stem")
		stemstate = block_set_state_id_value(block_current, stemstate, "tilt", "none")
		stemmodel = block_current.state_id_model_obj[stemstate].model[0]
		model.offset[Z] = block_size
		return [ stemmodel.rendermodel_id, model.rendermodel_id ]
	}
	
	// Only a neighboring dripleaf above turns this leaf into a stem
	if (!build_edge[ZP] && builder_get_block(build_pos[X], build_pos[Y], build_pos[Z] + 1) = block_current)
	{
		var facing = block_get_state_id_value(block_current, block_state_id_current, "facing");
		block_state_id_current = block_get_state_id(block_current, [ "type", "big_dripleaf_stem", "facing", facing, "tilt", "none" ])
	}
	
	return 0
}
