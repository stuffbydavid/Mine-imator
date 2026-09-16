/// temp_remove_lists()

function temp_remove_lists()
{
	with (app.bench_settings)
	{
		sortlist_remove(project_lib_list, other.id)
		sortlist_remove(project_all_list, other.id)
		if (project_selected = other.id)
		{
			project_selected = null
			preview.select = null
			preview.update = true
		}
	}
	
	temp_edit = sortlist_remove(app.lib_list, id)
}
