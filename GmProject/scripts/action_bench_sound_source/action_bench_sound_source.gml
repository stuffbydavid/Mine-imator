/// action_bench_sound_source(source)
/// @arg source

function action_bench_sound_source(source)
{
	var slist;
	switch (source)
	{
		case "music":	slist = bench_settings.music_list break
		case "project":	slist = bench_settings.project_list break
		default:		slist = bench_settings.sounds_list break
	}

	if (source = "project")
	{
		ds_list_clear(slist.list)
		for (var i = 0; i < ds_list_size(res_list.list); i++)
		{
			var res = res_list.list[|i]
			if (res.type = e_res_type.SOUND)
				ds_list_add(slist.list, [-1, res.display_name, res])
		}
		if (slist.selected != null && ds_list_find_index(res_list.list, slist.selected) < 0)
		{
			slist.select = null
			slist.selected = null
			slist.selected_name = ""
		}
		soundlist_update(slist)
	}

	if (slist = bench_settings.sound_list_current)
		return 0

	if (!bench_music_mode)
	{
		bench_music_stop()
		bench_sound_stop()
	}
	else
	{
		bench_sound_stop()
		with (bench_settings.preview)
		{
			sound_play_index = null
			sound_playing = false
		}
	}
	bench_settings.sound = null
	bench_settings.sound_list_current = slist

	with (bench_settings.preview)
	{
		select = null
		update = true
	}
	bench_clear()
	soundlist_update(slist)

	if (slist.select = null)
		soundlist_select_default(slist)

	if (source = "music" && bench_music_mode && instance_exists(bench_settings.music_res))
	{
		bench_settings.sound = bench_settings.music_res
		with (bench_settings.preview)
		{
			select = app.bench_settings.music_res
			sound_play_index = app.bench_settings.music_play_index
			sound_playing = audio_exists(sound_play_index) && audio_is_playing(sound_play_index)
			update = true
		}
	}
}
