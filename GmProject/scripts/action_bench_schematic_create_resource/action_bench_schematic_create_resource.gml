/// action_bench_schematic_create_resource()

function action_bench_schematic_create_resource()
{
	var res = bench_settings.scenery;
	if (res = null || res.creator != bench_settings)
		return 0
		
	var tladd = res.scenery_tl_add
	if (res.scenery_tl_prompt_amount > 0)
		tladd = question(text_get("loadsceneryaddtimelines", res.scenery_tl_prompt_amount))
	
	res_creator = app
	
	var rescopy = new_obj(obj_resource)
	with (res)
		res_copy(rescopy)
	
	with (rescopy)
	{
		filename = filename_name(filename_get_unique(app.project_folder + "/" + res.filename))
		ready = res.ready
		scenery_size = res.scenery_size
		scenery_structure = res.scenery_structure
		scenery_palette_size = res.scenery_palette_size
		scenery_tl_add = tladd
		if (ds_list_valid(res.scenery_tl_list))
		{
			scenery_tl_list = res.scenery_tl_list
			res.scenery_tl_list = null
		}
		else
		{
			scenery_tl_list = ds_list_create()
			res.scenery_tl_list = null
		}
		block_vbuffer = res.block_vbuffer
		res.block_vbuffer = null
		file_copy_lib(res.scenery_source, app.project_folder + "/" + filename)
		res_save_block_cache(app.project_folder + "/" + filename + ".meshcache")
	}
	
	sortlist_add(app.res_list, rescopy)
	bench_settings.scenery = rescopy
	
	with (res)
		instance_destroy()
}
