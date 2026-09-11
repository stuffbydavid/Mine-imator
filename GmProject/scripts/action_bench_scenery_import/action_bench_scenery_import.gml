/// action_bench_scenery_import()

function action_bench_scenery_import()
{
	if (action_bench_scenery(e_option.BROWSE))
	{
		action_bench_scenery_folder("project")
		bench_settings.scenery_selected = bench_settings.scenery
	}
}
