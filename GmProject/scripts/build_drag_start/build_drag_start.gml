/// @desc Prepares a block for dragging from the build picker or hotbar.

function build_drag_start(value, state = null, source = null, slot = -1)
{
	if (!place_build || build_first_person || build_drag_block != null || value[1] = "")
		return 0

	if (state = null)
	{
		var asset, search;
		asset = value[0] ? mc_assets.model_name_map[?value[1]] : mc_assets.block_name_map[?value[1]]
		search = string_lower(build_tool.build_picker.search_tbx.text)
		state = asset_picker_get_state(asset, search)

		if (value = build_tool.build_selected && search = "")
		{
			if (value[0])
				state = minecraft_asset_get_state(asset, build_settings.model_state)
			else
				state = minecraft_asset_get_state(asset, build_settings.block_state)
		}
	}

	build_drag_block = [ value[0], value[1], array_copy_1d(state) ]
	build_drag_source = source
	build_drag_source_slot = slot
	build_drag_target = null
	build_drag_target_slot = -1
	build_drag_insert = false
	build_drag_active = false

	var res = project_pack_res;
	if (build_structure != null && instance_exists(build_structure))
		res = build_structure.render_res_diffuse
	
	build_drag_res = res_eval(res)
}
