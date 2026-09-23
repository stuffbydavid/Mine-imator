/// bench_audio_track_update()
/// Pick the currently selected or last added audio track timeline for new sounds.

function bench_audio_track_update()
{
	with (app.bench_settings)
	{
		audio_track = null
		
		// Pick selection
		if (instance_exists(tl_edit) && tl_edit.type = e_tl_type.AUDIO_TRACK)
			audio_track = tl_edit
			
		// Pick last added
		else
		{
			for (var i = ds_list_size(app.project_timeline_list) - 1; i >= 0; i--)
			{
				var track = app.project_timeline_list[|i]
				if (track.type = e_tl_type.AUDIO_TRACK)
				{
					audio_track = track
					break
				}
			}
		}
	}
}