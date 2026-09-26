/// bench_sound_stop()

function bench_sound_stop()
{
	if (bench_settings.sound_list_current.source = "music")
		return 0

	with (bench_settings.preview)
		preview_sound_stop()
}
