/// @desc Returns the connected upper or lower block position.

function block_set_tall_block()
{
	var half, pos, state;
	half = block_get_state_id_value(block_current, block_state_id_current, "half")
	pos = array_copy_1d(build_pos)

	if (half = "lower")
		pos[Z]++
	else if (half = "upper")
		pos[Z]--
	else
		return null

	if (builder_get_block(pos[X], pos[Y], pos[Z]) != block_current)
		return null

	state = builder_get_state_id(pos[X], pos[Y], pos[Z])
	if (block_get_state_id_value(block_current, state, "half") != (half = "lower" ? "upper" : "lower"))
		return null

	// Legacy plant upper halves do not reliably store the lower half's variant
	if (!(builder_scenery_legacy && block_current.type = "double_plant") &&
		block_get_state_id_value(block_current, state, "variant") != block_get_state_id_value(block_current, block_state_id_current, "variant"))
		return null

	return vec3(pos[X], pos[Y], pos[Z])
}
