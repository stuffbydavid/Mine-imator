/// action_bench_schematic_open_folder()

function action_bench_schematic_open_folder()
{
	open_url(bench_schematic_folder = "project" ? project_folder : schematic_directory + bench_schematic_folder)
}
