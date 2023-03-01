/// action_bench_shape_tex_material(resource)
/// @arg resource

function action_bench_shape_tex_material(res)
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
			var fn = file_dialog_open_image();
			if (!file_exists_lib(fn))
				return 0
			
			res = new_res(fn, e_res_type.TEXTURE)
			with (res)
				res_load()
		}
		
		history_set_res(action_bench_shape_tex_material, fn, bench_settings.shape_tex_material, res)
	}
	
	bench_settings.shape_tex_material = res
	bench_settings.preview.update = true
}
