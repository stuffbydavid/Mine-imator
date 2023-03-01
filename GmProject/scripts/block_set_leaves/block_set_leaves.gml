/// block_set_leaves()
/// @desc Returns the opaque or transparent model.

function block_set_leaves()
{
	var model = block_current.state_id_model_obj[block_state_id_current].model[0];
	
	if (app.project_render_opaque_leaves)
		return model.opaque.rendermodel_id
	else
		return model.rendermodel_id
}
