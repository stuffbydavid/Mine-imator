function minecraft_game_load_sounds(soundslist, musiclist)
{
	soundlist_clear(soundslist)
	soundlist_clear(musiclist)
	
	if (!file_exists_lib(minecraft_game_assets_latest))
		return 0

	var map, objects;
	map = json_load(minecraft_game_assets_latest)
	if (!ds_map_valid(map))
		return 0

	objects = map[?"objects"]
	if (ds_map_valid(objects))
	{
		var prefix, path;
		prefix = "minecraft/sounds/"
		path = ds_map_find_first(objects)
		
		while (!is_undefined(path))
		{
			if (string_pos(prefix, path) = 1)
			{
				var sound = objects[?path];
				if (ds_map_valid(sound))
				{
					var hash = sound[?"hash"];
					if (is_string(hash))
					{
						var key, parsed;
						key = string_delete(path, 1, string_length(prefix))
						parsed = minecraft_parse_asset_key(key)
						
						if (parsed[0] = "music" || parsed[0] = "records")
						{
							if (parsed[0] = "music") // Parse music category
							{
								key = string_delete(key, 1, string_length(parsed[0]) + 1)
								parsed = minecraft_parse_asset_key(key)
							}
							
							var filter = ds_list_find_index(minecraft_music_filter_list, parsed[0]);
							if (filter < 0) // Other
								filter = ds_list_size(minecraft_music_filter_list) - 1
							
							ds_list_add(musiclist.list, [ filter, parsed[1], hash ])
						}
						else
						{
							var filter = ds_list_find_index(minecraft_sound_filter_list, parsed[0]);
							if (filter < 0) // Other
								filter = ds_list_size(minecraft_sound_filter_list) - 1
							
							ds_list_add(soundslist.list, [ filter, parsed[1], hash ])
						}
					}
				}
			}
			path = ds_map_find_next(objects, path)
		}
	}
	ds_map_destroy(map)

	soundlist_sort(soundslist.list)
	soundlist_sort(musiclist.list)
	
	soundlist_update(soundslist)
	soundlist_update(musiclist)
}
