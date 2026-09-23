/// sortlist_search_minecraft(name, search, model)

function sortlist_search_minecraft(name, search, model)
{
	var kind, asset;
	kind = model ? "model" : "block"
	asset = model ? mc_assets.model_name_map[?name] : mc_assets.block_name_map[?name]
	if (string_contains(string_lower(minecraft_asset_get_name(kind, name)), search))
		return 2

	for (var i = 0; i < array_length(asset.default_state); i += 2)
	{
		var state, statecurrent;
		state = asset.default_state[i]
		statecurrent = asset.states_map[?state]
		if (string_contains(string_lower(text_get(kind + "state" + state)), search))
			return 1
		for (var s = 0; s < statecurrent.value_amount; s++)
			if (string_contains(string_lower(minecraft_asset_get_name(kind + "statevalue", statecurrent.value_name[s])), search))
				return 1
	}
	
	return 0
}
