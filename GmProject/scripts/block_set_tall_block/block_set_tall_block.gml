/// @desc Returns the connected upper or lower block position.

function block_set_tall_block()
{
	var connected, pos, state;
	connected = block_get_connect(block_current, block_state_id_current)
	if (connected = null)
		return null

	// Validate the existing block at the connected position
	pos = vec3_add(build_pos, connected[0])
	if (builder_get_block(pos[X], pos[Y], pos[Z]) != block_current)
		return null

	state = builder_get_state_id(pos[X], pos[Y], pos[Z])
	if (block_get_state_id_value(block_current, state, "half") != block_get_state_id_value(block_current, connected[1], "half"))
		return null

	// Legacy plant upper halves do not reliably store the lower half's variant
	if (!(builder_scenery_legacy && block_current.type = "double_plant") &&
		block_get_state_id_value(block_current, state, "variant") != block_get_state_id_value(block_current, block_state_id_current, "variant"))
		return null

	return pos
}
