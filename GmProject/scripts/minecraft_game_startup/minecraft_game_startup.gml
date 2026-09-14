/// minecraft_game_startup()

function minecraft_game_startup()
{
	globalvar minecraft_game_version_latest, minecraft_sound_filter_list, minecraft_music_filter_list;
	
	// Load Java versions
	minecraft_game_version_latest = ""
	minecraft_sound_filter_list = ds_list_create()
	for (var i = 0; i < array_length(sound_filters); i++)
		ds_list_add(minecraft_sound_filter_list, sound_filters[i])
	minecraft_music_filter_list = ds_list_create()
	for (var i = 0; i < array_length(music_filters); i++)
		ds_list_add(minecraft_music_filter_list, music_filters[i])
	
	var dir, folder, latestid
	dir = minecraft_java_directory_get() + "/versions/"
	folder = file_find_first(dir + "*", 16)
	latestid = 0
	while (folder != "")
	{
		var filename = dir + folder + "/" + folder + ".json"
		if (file_exists_lib(filename))
		{
			var map = json_load(filename)
			if (ds_map_valid(map))
			{
				var assetindex = map[?"assetIndex"]
				if (ds_map_valid(assetindex))
				{
					var assetid = assetindex[?"id"]
					if (is_string(assetid) && assetid != "")
					{
						var assetideval = eval(assetid, 0)
						if (assetideval > latestid)
						{
							minecraft_game_version_latest = assetid
							latestid = assetideval
						}
					}
				}
				ds_map_destroy(map)
			}
		}

		folder = file_find_next()
	}
	file_find_close()
}
