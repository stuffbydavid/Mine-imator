/// app_startup_interface_bench()

function app_startup_interface_bench()
{
	bench_open = false
	bench_hover_ani = 0
	bench_hover_ani_goal = 0
	bench_click_ani = 0
	bench_click_ani_goal = 0
	bench_rotate_ani = 0
	bench_button_hover = false
	bench_show_ani_type = ""
	bench_show_ani = 0
	bench_settings_ani = 0
	bench_height = 325
	
	// Bench types
	bench_type_list = list_new()
	list_edit = bench_type_list
	list_edit.get_name = true
	list_edit.show_ticks = false
	
	list_item_add("typechar", e_tl_type.CHARACTER, "", null, icons.CHARACTER, null, bench_click)
	list_item_add("typebodypart", e_tl_type.BODYPART, "", null, icons.PART, null, bench_click)
	list_item_add("typemodel", e_tl_type.MODEL, "", null, icons.MODEL, null, bench_click)
	
	list_item_add("typeitem", e_tl_type.ITEM, "", null, icons.ITEM, null, bench_click)
	list_item_add("typescenery", e_tl_type.SCENERY, "", null, icons.SCENERY, null, bench_click)
	list_item_add("typeblock", e_tl_type.BLOCK, "", null, icons.BLOCK, null, bench_click)
	list_item_add("typespblock", e_tl_type.SPECIAL_BLOCK, "", null, icons.BLOCK_SPECIAL, null, bench_click)
	
	list_item_add("typeshape", e_tl_type.SHAPE, "", null, icons.SHAPES, null, bench_click)
	list_item_add("typetext", e_tl_type.TEXT, "", null, icons.TEXT, null, bench_click)
	list_item_add("typepath", e_tl_type.PATH, "", null, icons.PATH, null, bench_click)
	
	list_item_add("typecamera", e_tl_type.CAMERA, "", null, icons.CAMERA, null, bench_click)
	list_item_add("typeparticles", e_tl_type.PARTICLE_SPAWNER, "", null, icons.FIREWORKS, null, bench_click)
	list_item_add("typelightsource", e_tl_type.LIGHT_SOURCE, "", null, icons.LIGHT_POINT, null, bench_click)
	list_item_add("typeaudio", e_tl_type.AUDIO, "", null, icons.NOTE, null, bench_click)
	list_item_add("typebackground", e_tl_type.BACKGROUND, "", null, icons.CLOUD, null, bench_click)
	
	list_edit = null
	
	// Workbench settings
	bench_settings = new_obj(obj_bench_settings)
	with (bench_settings)
	{
		posx = 0
		posy = 0
		
		// Size
		height = 0
		height_goal = app.bench_height
		
		// Default settings
		temp_event_create()
		model_name = default_model
		model_state = array_copy_1d(mc_assets.model_name_map[?model_name].default_state)
		model_part_name = default_model_part
		temp_update_model()
		temp_update_model_part()
		temp_update_model_shape()
		block_state = array_copy_1d(mc_assets.block_name_map[?block_name].default_state)
		temp_particles_init()
		model_tex = mc_res
		model_tex_material = mc_res
		model_tex_normal = mc_res
		item_tex = mc_res
		item_tex_material = mc_res
		item_tex_normal = mc_res
		block_tex = mc_res
		block_tex_material = mc_res
		block_tex_normal = mc_res
		text_font = mc_res
		particle_preset = ""
		type = e_temp_type.CHARACTER
		shape_type = e_shape_type.CUBE
		light_type = e_tl_type.POINT_LIGHT
		
		// Preview window
		preview = new_obj(obj_preview)
		
		// Character list
		char_list = new_obj(obj_sortlist)
		char_list.script = action_bench_model_name
		sortlist_column_add(char_list, "charname", 0)
		for (var c = 0; c < ds_list_size(mc_assets.char_list); c++)
			sortlist_add(char_list, mc_assets.char_list[|c].name)
		
		// Item list
		item_scroll = new_obj(obj_scrollbar)
	
		// Block list
		block_list = new_obj(obj_sortlist)
		block_list.script = action_bench_block_name
		sortlist_column_add(block_list, "blockname", 0)
		for (var b = 0; b < ds_list_size(mc_assets.block_list); b++)
			if (!mc_assets.block_list[|b].timeline || mc_assets.block_list[|b].tl_model_name = "" || mc_assets.block_list[|b].model_double)
				sortlist_add(block_list, mc_assets.block_list[|b].name)
		
		// Special block list
		special_block_list = new_obj(obj_sortlist)
		special_block_list.script = action_bench_model_name
		sortlist_column_add(special_block_list, "spblockname", 0)
		for (var c = 0; c < ds_list_size(mc_assets.special_block_list); c++)
			sortlist_add(special_block_list, mc_assets.special_block_list[|c].name)
		
		// Bodypart list
		bodypart_model_list = new_obj(obj_sortlist)
		bodypart_model_list.script = action_bench_model_name
		sortlist_column_add(bodypart_model_list, "bodypartmodelname", 0)
		for (var m = 0; m < ds_list_size(mc_assets.char_list); m++)
			sortlist_add(bodypart_model_list, mc_assets.char_list[|m].name)
		for (var m = 0; m < ds_list_size(mc_assets.special_block_list); m++)
			sortlist_add(bodypart_model_list, mc_assets.special_block_list[|m].name)
		
		// Particles list
		particles_list = new_obj(obj_sortlist)
		particles_list.script = action_bench_particles
		sortlist_column_add(particles_list, "particlepresetname", 0)
	}
}
