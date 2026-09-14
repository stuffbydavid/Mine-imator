/// action_bench_sound(sound)

function action_bench_sound(sound)
{
	if (!is_array(sound))
		return 0

	var res, playindex, music, automusic;
	res = null
	music = bench_settings.sound_list_current = bench_settings.music_list
	automusic = !music && bench_music_mode && (!audio_exists(bench_settings.music_play_index) || !audio_is_playing(bench_settings.music_play_index))
	music = music || automusic
	
	// Minecraft sound
	if (is_string(sound[2]))
	{
		var hash, source, destination;
		hash = sound[2]
		source = minecraft_java_directory_get() + "/assets/objects/" + string_copy(hash, 1, 2) + "/" + hash
		destination = file_directory + "tmp.ogg"
		if (!file_exists_lib(source))
			return 0

		if (!bench_music_mode || music)
			bench_music_stop()
		if (!automusic)
		{
			with (bench_settings.preview)
				preview_sound_stop()
		
			bench_settings.sound = null
			bench_clear()
		}
		
		file_copy_lib(source, destination)
		if (!file_exists_lib(destination))
			return 0

		res_creator = bench_settings
		res = new_obj(obj_resource)
		res_creator = app
		res.type = e_res_type.SOUND
		res.filename = "tmp.ogg"
		res.minecraft_hash = hash
		res.display_name = sound[1]

		load_folder = file_directory
		save_folder = file_directory
		with (res)
			res_load()
	}

	// Resource
	else if (instance_exists(sound[2]) && sound[2].type = e_res_type.SOUND)
	{
		if (!bench_music_mode || music)
			bench_music_stop()
		if (!automusic)
		{
			with (bench_settings.preview)
				preview_sound_stop()
		
			bench_settings.sound = null
			bench_clear()
		}
		res = sound[2]
	}
	else
		return 0

	if (!automusic)
		bench_settings.sound = res
	
	if (music)
	{
		bench_settings.music_res = res
		
		var history = bench_settings.music_history;
		ds_list_delete_value(history, sound[2])
		ds_list_add(history, sound[2])
		
		while (ds_list_size(history) > 20)
			ds_list_delete(history, 0)
			
		bench_settings.music_autoplay = true
	}
	
	if (!automusic)
	{
		bench_settings.sound_list_current.select = sound
		bench_settings.sound_list_current.selected = sound[2]
		bench_settings.sound_list_current.selected_name = sound[1]
	}
	else
	{
		bench_settings.music_list.select = sound
		bench_settings.music_list.selected = sound[2]
		bench_settings.music_list.selected_name = sound[1]
	}
	
	playindex = audio_play_sound(res.sound_index, 0, false)

	if (music)
		bench_settings.music_play_index = playindex
	
	if (!automusic)
		with (bench_settings.preview)
		{
			select = res
			update = true
			sound_play_index = playindex
		}
	return res
}
