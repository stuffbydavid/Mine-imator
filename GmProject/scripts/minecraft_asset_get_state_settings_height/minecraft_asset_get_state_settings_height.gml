/// @desc Returns the height required for an asset's state controls.
/// @arg asset

function minecraft_asset_get_state_settings_height(asset)
{
	var checkboxes, menus, states;
	checkboxes = 0
	menus = 0
	states = asset.default_state

	for (var i = 0; i < array_length(states); i += 2)
	{
		if (states[i + 1] = "true" || states[i + 1] = "false")
			checkboxes++
		else
			menus++
	}

	return ceil(checkboxes / 2) * (ui_small_height + 8) + menus * 32
}
