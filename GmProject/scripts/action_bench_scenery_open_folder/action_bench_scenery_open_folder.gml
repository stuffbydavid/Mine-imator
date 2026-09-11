/// action_bench_scenery_open_folder()

function action_bench_scenery_open_folder()
{
	open_url(bench_scenery_folder = "project" ? project_folder : scenery_directory + bench_scenery_folder)
}
