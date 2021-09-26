/// action_bench_block_material_tex(resource)
/// @arg resource

function action_bench_block_material_tex(res)
{
	var fn = "";
	
	if (history_undo)
		res = history_undo_res()
	else if (history_redo)
		res = history_redo_res()
	else
	{
		if (res = e_option.BROWSE)
		{
			fn = file_dialog_open_image_pack()
			if (!file_exists_lib(fn))
				return 0
			
			res = new_res(fn, e_res_type.BLOCK_SHEET)
			with (res)
				res_load()
		}
		history_set_res(action_bench_block_material_tex, fn, bench_settings.block_material_tex, res)
	}
	
	bench_settings.block_material_tex = res
	bench_settings.preview.update = true
}
