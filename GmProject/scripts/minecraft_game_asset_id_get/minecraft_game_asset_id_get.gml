/// CppSeparate StringType minecraft_game_asset_id_get(StringType)
/// @arg filename

function minecraft_game_asset_id_get(filename)
{
	var map, assetid;
	map = json_load(filename)
	assetid = ""

	if (ds_map_valid(map))
	{
		var assetindex = map[?"assetIndex"];
		if (ds_map_valid(assetindex))
			assetid = value_get_string(assetindex[?"id"], "")

		ds_map_destroy(map)
	}

	return assetid
}
