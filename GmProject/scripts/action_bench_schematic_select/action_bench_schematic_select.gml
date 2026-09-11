/// action_bench_schematic_select(schematic)
/// @arg schematic

function action_bench_schematic_select(schematic)
{
	bench_clear()
	
	if (is_string(schematic))
	{
		var folder, res;
		folder = schematic_directory + bench_schematic_folder
		res_creator = bench_settings
		res = new_obj(obj_resource)
		res_creator = app
		
		with (res)
		{
			type = e_res_type.SCENERY
			filename = schematic + ".schematic"
			scenery_source = folder + "/" + filename
		}
		
		load_folder = folder
		save_folder = folder
		with (res)
			res_load()
		
		bench_settings.scenery = res
	}
	else
		bench_settings.scenery = schematic
		
	bench_settings.schematic_selected = schematic
	with (bench_settings.preview)
	{
		preview_reset_view()
		reset_view = true
		update = true
	}
}
