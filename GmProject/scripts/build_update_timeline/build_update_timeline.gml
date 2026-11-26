/// @desc Updates timeline placement options for the selected build block.

function build_update_timeline(reset = true)
{
	var block = null;
	if (build_settings.type = e_temp_type.BLOCK)
		block = mc_assets.block_name_map[?build_settings.block_name]
	else
	{
		var data = block_get_from_timeline(build_settings.model_name, build_settings.model_state);
		if (data != null)
			block = block_objs[data[0]]
	}

	build_timeline_required = (block = null || (block.timeline && ds_map_exists(mc_assets.block_tl_required_map, block.tl_type)))
	if (reset)
		build_timeline = (build_timeline_required || (block.timeline && ds_list_find_index(mc_assets.block_timeline_enabled_list, block.tl_type) >= 0))
}
