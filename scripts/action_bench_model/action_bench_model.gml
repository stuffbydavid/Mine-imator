/// action_bench_model(resource)
/// @arg resource
/// @desc Sets the model of the workbench.

var res, fn;
fn = ""

if (history_undo)
	res = history_undo_res()
else if (history_redo)
	res = history_redo_res()
else
{
	res = argument0
	if (res = e_option.BROWSE)
	{
		fn = file_dialog_open_model()
		
		if (!file_exists_lib(fn))
			return 0
		
		res = new_res(fn, e_res_type.MODEL)
		if (res.replaced)
			action_res_replace(fn)
		else
			with (res)
				res_load()
	}
	history_set_res(action_bench_model, fn, bench_settings.model, res)
}

with (bench_settings)
{
	model = res
	temp_update_model()
	
	with (preview)
	{
		preview_reset_view()
		update = true
	}
}
