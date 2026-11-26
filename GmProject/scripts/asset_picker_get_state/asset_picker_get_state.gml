/// @desc Returns the current asset state with a temporary search match.
/// @arg asset
/// @arg [search]

function asset_picker_get_state(asset, search = "")
{
	var vars = asset_picker_state_map[?asset];
	if (is_undefined(vars))
	{
		vars = array_copy_1d(asset.default_state)
		asset_picker_state_map[?asset] = vars
	}

	return minecraft_asset_get_state(asset, vars, search)
}
