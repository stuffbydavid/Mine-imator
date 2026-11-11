/// @desc Updates a state setting for all compatible picker assets.
/// @arg name
/// @arg value

function asset_picker_set_state(name, value)
{
	var lists = [ mc_assets.char_list, mc_assets.equipment_list, mc_assets.block_list, mc_assets.special_block_list ];
	for (var l = 0; l < array_length(lists); l++)
	{
		var assets = lists[l];
		for (var i = 0; i < ds_list_size(assets); i++)
		{
			var asset, setting, vars;
			asset = assets[|i]

			if (asset.states_map = null)
				continue

			setting = asset.states_map[?name]
			if (is_undefined(setting) || !array_contains(setting.value_name, value))
				continue

			vars = asset_picker_get_state(asset)
			state_vars_set_value(vars, name, value)
			
			asset_picker_state_map[?asset] = vars
		}
	}
}
