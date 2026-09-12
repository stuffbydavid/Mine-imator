/// action_bench_schematic_import()

function action_bench_schematic_import()
{
	if (action_bench_schematic(e_option.BROWSE))
	{
		bench_settings.schematic_selected = bench_settings.scenery
		action_bench_schematic_folder("project")
	}
}
