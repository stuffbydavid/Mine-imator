function block_set_piston()
{
	var staticmodel = (!mc_builder.block_tl_add || block_tl_map = null);

	if (mc_builder.block_tl_types != null && !array_contains(mc_builder.block_tl_types, block_current.tl_type))
		staticmodel = true

	if (staticmodel)
		block_state_id_current = block_set_state_id_value(block_current, block_state_id_current, "extended", "false")

	return 0
}
