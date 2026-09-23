/// action_bench_sound_import()

function action_bench_sound_import()
{
	var fn, res;
	fn = file_dialog_open_sound()
	if (!file_exists_lib(fn))
		return 0

	res = new_res(fn, e_res_type.SOUND)
	if (bench_settings.sound_list_current = bench_settings.project_sounds_list)
		with (bench_settings.preview)
			if (sound_play_index != app.bench_settings.music_play_index)
				preview_sound_stop()
	
	res.loaded = true
	with (res)
		res_load()
	project_reset_loaded()

	action_bench_sound_source("project")
	
	bench_settings.sound = res
	bench_settings.sound_list_current.select = [-1, res.display_name, res]
	bench_settings.sound_list_current.selected = res
	bench_settings.sound_list_current.selected_name = res.display_name

	with (bench_settings.preview)
	{
		select = res
		update = true
	}
}
