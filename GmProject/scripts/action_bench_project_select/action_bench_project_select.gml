/// action_bench_project_select(asset)

function action_bench_project_select(asset)
{
	bench_settings.project_selected = asset
	if ((bench_settings.project_list = bench_settings.project_lib_list || bench_settings.project_list = bench_settings.project_all_list) &&
		asset != null && instance_exists(asset) && asset.object_index = obj_template)
		bench_settings.project_list.script_select_click = action_bench_create
	else
		bench_settings.project_list.script_select_click = null
	
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
