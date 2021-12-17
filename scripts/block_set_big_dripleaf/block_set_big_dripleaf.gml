/// block_set_big_dripleaf()
/// @desc Sets stem state for below dripleaf blocks.

if ((builder_scenery && !builder_scenery_legacy) || block_get_state_id_value(block_current, block_state_id_current, "type") = "big_dripleaf_stem")
	return 0

if (build_pos_z != (build_size_z - 1))
{
	var facing = block_get_state_id_value(block_current, block_state_id_current, "facing")
	block_state_id_current = block_get_state_id(block_current, array("type", "big_dripleaf_stem", "facing", facing, "tilt", "none"))
}

return 0