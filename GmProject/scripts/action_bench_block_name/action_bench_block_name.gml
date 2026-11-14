/// @desc Sets the block name of the workbench settings.

function action_bench_block_name(name, state = null)
{
	var settings, picker, search;
	
	if (place_build)
	{
		settings = build_settings
		picker = build_tool.build_picker
	}
	else
	{
		settings = bench_settings
		picker = bench_settings.block_picker
	}
	
	search = string_lower(picker.search_tbx.text)
	if (state = null)
		state = asset_picker_get_state(mc_assets.block_name_map[?name], search)
	
	asset_picker_state_map[?mc_assets.block_name_map[?name]] = array_copy_1d(state)
	
	with (settings)
	{
		if (block_name = name && array_equals(block_state, state))
			return 0
		
		block_name = name
		block_state = array_copy_1d(state)
		
		temp_update_block()
		
		if (preview != null)
			preview.update = true
	}
}
