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
	bench_height = 345
	bench_schematic_folder = schematic_folders[0]
	
	// Workbench tabs
	bench_tab = e_bench.CHARACTER
	bench_tab_list = list_new()
	list_edit = bench_tab_list
	list_edit.get_name = true
	list_edit.show_ticks = false
	
	list_item_add("typechar", e_bench.CHARACTER, "", null, icons.CHARACTER, null, bench_click)
	if (ds_list_size(mc_assets.equipment_list) > 0)
		list_item_add("typeequipment", e_bench.EQUIPMENT, "", null, icons.SHIELD, null, bench_click)
	list_item_add("typemodel", e_bench.MODEL, "", null, icons.MODEL, null, bench_click)
	list_item_add("typemodelpart", e_bench.MODEL_PART, "", null, icons.PART, null, bench_click)
	
	list_item_add("typeitem", e_bench.ITEM, "", null, icons.ITEM, null, bench_click)
	list_item_add("typeworld", e_bench.WORLD, "", null, icons.SCENERY, null, bench_click)
	list_item_add("typeschematic", e_bench.SCHEMATIC, "", null, icons.HOUSE, null, bench_click)
	list_item_add("typeblock", e_bench.BLOCK, "", null, icons.BLOCK, null, bench_click)
	list_item_add("typespblock", e_bench.SPECIAL_BLOCK, "", null, icons.BLOCK_SPECIAL, null, bench_click)
	
	list_item_add("typeshape", e_bench.SHAPE, "", null, icons.SHAPES, null, bench_click)
	list_item_add("typetext", e_bench.TEXT, "", null, icons.TEXT, null, bench_click)
	list_item_add("typepath", e_bench.PATH, "", null, icons.PATH, null, bench_click)
	
	list_item_add("typecamera", e_bench.CAMERA, "", null, icons.CAMERA, null, bench_click)
	list_item_add("typeparticles", e_bench.PARTICLE_SPAWNER, "", null, icons.FIREWORKS, null, bench_click)
	list_item_add("typelightsource", e_bench.LIGHT_SOURCE, "", null, icons.LIGHT_POINT, null, bench_click)
	list_item_add("typeaudio", e_bench.AUDIO, "", null, icons.NOTE, null, bench_click)
	list_item_add("typebackground", e_bench.ENVIRONMENT, "", null, icons.CLOUD, null, bench_click)
	
	list_edit = null
	
	// Preview
	bench_tab_preview = array(
		e_bench.CHARACTER,
		e_bench.EQUIPMENT,
		e_bench.MODEL,
		e_bench.MODEL_PART,
		e_bench.ITEM,
		e_bench.SCHEMATIC,
		e_bench.BLOCK,
		e_bench.SPECIAL_BLOCK,
		e_bench.SHAPE,
		e_bench.TEXT,
		e_bench.PARTICLE_SPAWNER
	)

	// Workbench settings
	bench_settings = new_obj(obj_bench_settings)
	with (bench_settings)
	{
		type = null
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
		char_list.visible_items = 7
		char_list.script = action_bench_model_name
		sortlist_column_add(char_list, "charname", 0)
		for (var c = 0; c < ds_list_size(mc_assets.char_list); c++)
			sortlist_add(char_list, mc_assets.char_list[|c].name)

		// Equipment list
		equipment_list = new_obj(obj_sortlist)
		equipment_list.visible_items = 6
		equipment_list.script = action_bench_model_name
		equipment_list.header_show = false
		sortlist_column_add(equipment_list, "spblockname", 0)
		for (var c = 0; c < ds_list_size(mc_assets.equipment_list); c++)
			sortlist_add(equipment_list, mc_assets.equipment_list[|c].name)
		
		// Model part list
		model_part_model_list = new_obj(obj_sortlist)
		model_part_model_list.visible_items = 6
		model_part_model_list.script = action_bench_model_name
		sortlist_column_add(model_part_model_list, "modelpartmodelname", 0)
		for (var m = 0; m < ds_list_size(mc_assets.equipment_list); m++)
			sortlist_add(model_part_model_list, mc_assets.equipment_list[|m].name)
		for (var m = 0; m < ds_list_size(mc_assets.char_list); m++)
			sortlist_add(model_part_model_list, mc_assets.char_list[|m].name)
		for (var m = 0; m < ds_list_size(mc_assets.special_block_list); m++)
			sortlist_add(model_part_model_list, mc_assets.special_block_list[|m].name)
		
		// Item list
		item_scroll = new_obj(obj_scrollbar)
			
		// Schematic list
		schematic_list = new_obj(obj_sortlist)
		schematic_list.visible_items = 6
		schematic_list.script = action_bench_schematic_select
		schematic_list.header_show = false
		sortlist_column_add(schematic_list, "schematicname", 0)
		schematic_list.column_sort = 0
		schematic_list.sort_asc = false
		schematic_selected = null
	
		// Block list
		block_list = new_obj(obj_sortlist)
		block_list.visible_items = 7
		block_list.script = action_bench_block_name
		sortlist_column_add(block_list, "blockname", 0)
		for (var b = 0; b < ds_list_size(mc_assets.block_list); b++)
			if (!mc_assets.block_list[|b].timeline || mc_assets.block_list[|b].tl_model_name = "" || mc_assets.block_list[|b].model_double)
				sortlist_add(block_list, mc_assets.block_list[|b].name)
		
		// Special block list
		special_block_list = new_obj(obj_sortlist)
		special_block_list.visible_items = 6
		special_block_list.script = action_bench_model_name
		sortlist_column_add(special_block_list, "spblockname", 0)
		for (var c = 0; c < ds_list_size(mc_assets.special_block_list); c++)
			sortlist_add(special_block_list, mc_assets.special_block_list[|c].name)
		
		// Shape list
		shape_list = new_obj(obj_sortlist)
		shape_list.visible_items = e_shape_type.amount - 1
		shape_list.script = action_bench_shape_type
		shape_list.header_show = false
		sortlist_column_add(shape_list, "shapename", 0)
		for (var i = 0; i < e_shape_type.amount; i++)
			sortlist_add(shape_list, i)
		
		// Particles list
		particles_list = new_obj(obj_sortlist)
		particles_list.visible_items = 8
		particles_list.script = action_bench_particles
		particles_list.header_show = false
		sortlist_column_add(particles_list, "particlepresetname", 0)
	}
}
