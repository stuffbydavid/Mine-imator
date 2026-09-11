/// action_bench_schematic(resource)
/// @arg resource
/// @desc Sets the schematic of the workbench.

function action_bench_schematic(res)
{
	if (history_undo)
		res = history_undo_res()
	else if (history_redo)
		res = history_redo_res()
	else
	{
		var fn = "";
		
		if (res = e_option.BROWSE)
		{
			fn = file_dialog_open_scenery()
			
			if (!file_exists_lib(fn))
				return false
			
			res = new_res(fn, e_res_type.SCENERY)
			if (res.replaced)
			{
				res_edit = res
				action_res_replace(fn)
			}
			else
				with (res)
					res_load()
		}
		history_set_res(action_bench_schematic, fn, bench_settings.scenery, res)
	}
	
	bench_settings.scenery = res
	bench_settings.preview.update = true
	
	return true
}
