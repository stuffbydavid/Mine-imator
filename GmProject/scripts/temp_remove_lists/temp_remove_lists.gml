/// temp_remove_lists()

function temp_remove_lists()
{
	with (app)
	{
		var libpos, allpos;
		libpos = sortlist_remove(bench_settings.project_lib_list, other.id)
		allpos = sortlist_remove(bench_settings.project_all_list, other.id)

		if (bench_settings.project_selected = other.id)
			action_bench_project_select(bench_settings.project_list = bench_settings.project_lib_list ? libpos : allpos)
	}
	
	temp_edit = sortlist_remove(app.lib_list, id)
}
