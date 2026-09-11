/// action_bench_scenery_select(scenery)
/// @arg scenery

function action_bench_scenery_select(scenery)
{
	bench_clear()
	
	if (is_string(scenery))
	{
		var folder, res;
		folder = scenery_directory + bench_scenery_folder
		res_creator = bench_settings
		res = new_obj(obj_resource)
		res_creator = app
		
		with (res)
		{
			type = e_res_type.SCENERY
			filename = scenery + ".schematic"
			scenery_source = folder + "/" + filename
		}
		
		load_folder = folder
		save_folder = folder
		with (res)
			res_load()
		
		bench_settings.scenery = res
	}
	else
		bench_settings.scenery = scenery
		
	bench_settings.scenery_selected = scenery
	bench_settings.preview.reset_view = true
	bench_settings.preview.update = true
}
