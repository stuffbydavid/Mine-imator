/// res_remove_lists()

function res_remove_lists()
{
	with (app.bench_settings)
	{
		sortlist_remove(project_res_list, other.id)
		sortlist_remove(project_all_list, other.id)
		if (project_selected = other.id)
		{
			project_selected = null
			preview.select = null
			preview.update = true
		}
	}
	
	res_edit = sortlist_remove(app.res_list, id)
}
