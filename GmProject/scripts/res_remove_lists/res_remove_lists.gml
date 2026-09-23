/// res_remove_lists()

function res_remove_lists()
{
	with (app)
	{
		var respos, allpos;
		respos = sortlist_remove(bench_settings.project_res_list, other.id)
		allpos = sortlist_remove(bench_settings.project_all_list, other.id)

		if (bench_settings.project_selected = other.id)
			action_bench_project_select(bench_settings.project_list = bench_settings.project_res_list ? respos : allpos)
	}
	
	res_edit = sortlist_remove(app.res_list, id)
}
