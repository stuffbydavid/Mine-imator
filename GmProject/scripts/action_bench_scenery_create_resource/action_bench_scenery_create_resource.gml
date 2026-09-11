/// action_bench_scenery_create_resource(settings)
/// @arg settings

function action_bench_scenery_create_resource(settings)
{
	var scenery = settings.scenery
	if (scenery = null || scenery.creator != settings)
		return 0
	var scenerytladd = scenery.scenery_tl_add
	if (scenery.scenery_tl_prompt_amount > 0)
		scenerytladd = question(text_get("loadsceneryaddtimelines", scenery.scenery_tl_prompt_amount))
	
	res_creator = app
	var res = new_obj(obj_resource)
	with (scenery)
		res_copy(res)
	
	res.filename = filename_name(filename_get_unique(app.project_folder + "/" + scenery.filename))
	res.ready = scenery.ready
	res.scenery_size = scenery.scenery_size
	res.scenery_structure = scenery.scenery_structure
	res.scenery_palette_size = scenery.scenery_palette_size
	res.scenery_tl_add = scenerytladd
	res.scenery_tl_list = scenery.scenery_tl_list
	scenery.scenery_tl_list = null
	res.block_vbuffer = scenery.block_vbuffer
	scenery.block_vbuffer = null
	file_copy_lib(scenery.scenery_source, app.project_folder + "/" + res.filename)
	with (res)
		res_save_block_cache(app.project_folder + "/" + filename + ".meshcache")
	
	sortlist_add(app.res_list, res)
	settings.scenery = res
	settings.scenery_selected = res
	with (scenery)
		instance_destroy()
}
