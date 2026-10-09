function project_startup()
{
	globalvar load_queue, load_format, load_folder, save_folder,
			  temp_edit, ptype_edit, tl_edit_amount, tl_edit, obj_edit, res_edit, axis_edit, biome_color_edit, camera_effect_type_edit,
			  temp_creator, res_creator, save_id_seed, save_id_map, tl_focus;
	
	load_queue = ds_priority_create()
	
	temp_edit = null
	ptype_edit = null
	tl_edit = null
	tl_edit_amount = 0
	obj_edit = null
	res_edit = null
	axis_edit = X
	biome_color_edit = null
	camera_effect_type_edit = null
	
	temp_creator = app
	res_creator = app
	
	save_id = "root"
	save_id_seed = random_get_seed()
	save_id_map = ds_map_create()
	
	tl_focus = null
	
	project_bend_style = "blocky"
}
