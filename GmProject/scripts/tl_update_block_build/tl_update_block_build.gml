/// @desc Updates or removes the hidden block data retained for this timeline.
/// @arg [remove]
/// @arg [waterlogged]

function tl_update_block_build(remove = false, waterlogged = null)
{
	if (block_timeline || block_build_name = "" || parent = app || !type_is_structure(parent.type))
		return null

	var block = mc_assets.block_name_map[?block_build_name];
	if (is_undefined(block) || block = null || !block.tl_mesh || ds_list_find_index(parent.parent.tree_list, parent) < 0)
		return null

	// Timeline positions are relative to their structure and include the block's anchor
	var stateid, anchor, pos, target;
	stateid = block_get_state_id(block, block_build_state)
	anchor = block_get_timeline_position(block, stateid)
	pos = vec3_sub(tl_value_get_vec3(e_value.POS_X), vec3(anchor[Y], block_size - anchor[X], anchor[Z]))
	pos = vec3(floor(pos[X] / block_size + 0.001), floor(pos[Y] / block_size + 0.001), floor(pos[Z] / block_size + 0.001))
	target = parent

	with (target)
	{
		if (remove)
		{
			var current = block_meshes_get_block(pos[X], pos[Y], pos[Z]);
			if (current[0] = block.block_id && block_get_state_id_value(block, current[1], "visible") = "false")
				return tl_update_block_meshes(pos, 0, 0, [ [ pos, 0, 0, false ] ])
		}
		else
		{
			var meshstate = block_set_state_id_value(block, stateid, "visible", "false");

			// History restores the original waterlogging instead of inheriting air
			if (waterlogged != null)
				return tl_update_block_meshes(pos, 0, 0, [ [ pos, block.block_id, meshstate, waterlogged ] ])

			return tl_update_block_meshes(pos, block.block_id, meshstate)
		}
	}

	return null
}
