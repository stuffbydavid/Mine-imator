function action_bench_schematic_create_resource()
{
	var res = bench_settings.scenery;
	if (res = null || res.creator != bench_settings)
		return null

	res_creator = app
	
	var rescopy = new_obj(obj_resource);
	with (res)
		res_copy(rescopy)
	
	with (rescopy)
	{
		filename = filename_name(filename_get_unique(app.project_folder + "/" + res.filename))
		ready = res.ready
		
		scenery_size = res.scenery_size
		
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
		block_vbuffer_active = res.block_vbuffer_active
		block_vbuffer_depth_active = res.block_vbuffer_depth_active
		
		res.block_vbuffer = null
		
		file_copy_lib(res.scenery_source, app.project_folder + "/" + filename)
		
		res_update_display_name()
		res_save_block_cache(app.project_folder + "/" + filename + ".meshcache")
	}
	
	with (rescopy)
		res_add_lists()
	
	bench_settings.scenery = rescopy
	
	with (res)
		instance_destroy()
	
	return rescopy
}
