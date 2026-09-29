/// @arg soundlist

function soundlist_select_default(slist)
{
	if (slist.select != null)
		return true

	if (slist.source = "project")
		return false

	var musicplaying, defaultname;
	musicplaying = audio_exists(app.bench_settings.music_play_index) &&
		(audio_is_playing(app.bench_settings.music_play_index) || audio_is_paused(app.bench_settings.music_play_index))
	if (musicplaying)
		return false

	defaultname = slist.source = "music" ? music_default : sound_default
	for (var i = 0; i < ds_list_size(slist.display_list); i++)
	{
		var row = slist.display_list[|i];
		if (row[1] != defaultname)
			continue

		slist.select = row
		slist.selected = row[2]
		slist.selected_name = row[1]
		
		sortlist_view(slist, row)
		
		return true
	}

	return false
}
