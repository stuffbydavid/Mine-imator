/// action_bench_scenery(resource)
/// @arg resource
/// @desc Sets the scenery of the workbench.

var res, fn;
fn = ""

if (history_undo)
	res = history_undo_res()
else if (history_redo)
	res = history_redo_res()
else
{
	res = argument0
	if (res = e_option.IMPORT_WORLD)
	{
		fn = data_directory + "export.blocks"
		file_delete_lib(fn)
		execute(import_file, fn, true)
		
		if (!file_exists_lib(fn))
			return 0
		
		res = new_res(fn, "schematic")
		with (res)
			res_load()
	}
	else if (res = e_option.BROWSE)
	{
		fn = file_dialog_open_scenery()
		
		if (!file_exists_lib(fn))
			return 0
		
		res = new_res(fn, "schematic")
		with (res)
			res_load()
	}
	history_set_res(action_bench_scenery, fn, bench_settings.scenery, res)
}

bench_settings.scenery = res
bench_settings.preview.update = true
