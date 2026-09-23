/// soundlist_load(sounds, music)

function soundlist_load(sounds, music)
{
	var filename, map, objects;

	soundlist_clear(sounds)
	soundlist_clear(music)
	
	filename = minecraft_java_directory_get() + "/assets/indexes/" + minecraft_game_version_latest + ".json"
	if (!file_exists_lib(filename))
		return 0

	map = json_load(filename)
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
						parsed = minecraft_parse_key(key)
						
						if (parsed[0] = "music" || parsed[0] = "records")
						{
							if (parsed[0] = "music") // Parse music category
							{
								key = string_delete(key, 1, string_length(parsed[0]) + 1)
								parsed = minecraft_parse_key(key)
							}
							
							var filter = ds_list_find_index(minecraft_music_filter_list, parsed[0]);
							if (filter < 0) // Other
								filter = ds_list_size(minecraft_music_filter_list) - 1
							
							ds_list_add(music.list, [filter, parsed[1], hash])
						}
						else
						{
							var filter = ds_list_find_index(minecraft_sound_filter_list, parsed[0]);
							if (filter < 0) // Other
								filter = ds_list_size(minecraft_sound_filter_list) - 1
							
							ds_list_add(sounds.list, [filter, parsed[1], hash])
						}
					}
				}
			}
			path = ds_map_find_next(objects, path)
		}
	}
	ds_map_destroy(map)

	soundlist_sort(sounds.list)
	soundlist_sort(music.list)
	
	soundlist_update(sounds)
	soundlist_update(music)
}
