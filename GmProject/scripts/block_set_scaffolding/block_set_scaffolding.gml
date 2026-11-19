/// @desc Updates the bottom state of the scaffolding block.

function block_set_scaffolding()
{
	if (builder_scenery && !builder_scenery_legacy)
		return 0
		
	if (!build_edit && !builder_scenery)
		return 0

	var bottom = "true";
	if (!build_edge[ZN] && builder_get_block(build_pos[X], build_pos[Y], build_pos[Z] - 1) != null)
		bottom = "false"
	
	block_state_id_current = block_set_state_id_value(block_current, block_state_id_current, "bottom", bottom)

	return 0
}
