/// action_bench_text_font(resource)
/// @arg resource

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
		fn = file_dialog_open_font()
		if (!file_exists_lib(fn))
			return 0
		
		res = new_res("font", fn)
		with (res)
			res_load()
	}
	history_set_res(action_bench_text_font, fn, bench_settings.text_font, res)
}

bench_settings.text_font = res
bench_settings.preview.update = true
