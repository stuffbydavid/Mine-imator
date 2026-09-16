/// action_bench_project_select(asset)

function action_bench_project_select(asset)
{
	bench_settings.project_selected = asset
	
	with (bench_settings.preview)
	{
		if (select != asset)
			preview_sound_stop()
		select = asset
		update = true
	}
	
	if (asset = null)
		return 0
}
