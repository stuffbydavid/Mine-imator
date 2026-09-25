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
	bench_width = setting_bench_width
	bench_height_add = setting_bench_height - bench_initial_height
	bench_resize_width = bench_width
	bench_resize_height = bench_initial_height
	
	bench_schematic_folder = schematic_folders[0]
	bench_music_mode = false
	bench_particle_preset_folder = particle_folders[0]
	
	// Workbench tabs
	bench_tab = e_bench.CHARACTER
	bench_tab_list = list_new()
	list_edit = bench_tab_list
	list_edit.get_name = true
	list_edit.show_ticks = false
	
	list_item_add("typeproject", e_bench.PROJECT, "", null, icons.LIBRARY, null, bench_click)
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
	
	list_item_add("typecamera", e_bench.CAMERA, "", null, icons.CAMERA, null, bench_click)
	list_item_add("typesound", e_bench.SOUND, "", null, icons.VOLUME, null, bench_click)
	list_item_add("typeaudio", e_bench.AUDIO_TRACK, "", null, icons.NOTE, null, bench_click)
	list_item_add("typeparticles", e_bench.PARTICLE_SPAWNER, "", null, icons.FIREWORKS, null, bench_click)
	list_item_add("typetext", e_bench.TEXT, "", null, icons.TEXT, null, bench_click)
	
	list_item_add("typecameraeffects", e_bench.CAMERA_EFFECTS, "", null, icons.WAND, null, bench_click)
	list_item_add("typelightsource", e_bench.LIGHT_SOURCE, "", null, icons.LIGHT_POINT, null, bench_click)
	list_item_add("typepath", e_bench.PATH, "", null, icons.PATH, null, bench_click)
	list_item_add("typebackground", e_bench.ENVIRONMENT, "", null, icons.CLOUD, null, bench_click)
	list_item_add("typeshape", e_bench.SHAPE, "", null, icons.SHAPES, null, bench_click)
	
	bench_advanced_tabs = array(
		e_bench.PROJECT,
		e_bench.MODEL,
		e_bench.AUDIO_TRACK,
		e_bench.CAMERA_EFFECTS,
		e_bench.ENVIRONMENT
	)
	
	list_edit = null
	
	// Preview
	bench_tab_preview = array(
		e_bench.PROJECT,
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
		e_bench.SOUND,
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
		height_goal = bench_initial_height
		height_min = bench_initial_height
		height_fixed = array_create(e_bench.amount, 0)
		height_fixed_base = array_create(e_bench.amount, 0)
		list_height = 0
		list_minimum_height = 0
		list_focus = ""
		
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
		model_tex = project_pack_res
		model_tex_material = project_pack_res
		model_tex_normal = project_pack_res
		item_tex = project_pack_res
		item_tex_material = project_pack_res
		item_tex_normal = project_pack_res
		block_tex = project_pack_res
		block_tex_material = project_pack_res
		block_tex_normal = project_pack_res
		text_font = project_pack_res
		text_aa = false
		text_outline = false
		text_outline_color = c_red
		text_outline_size = 3
		text_halign = "center"
		text_valign = "center"
		text = ""
		tbx_text = new_textbox(false, 0, "")
		tbx_text_outline_size = new_textbox_integer()
		particle_preset = ""
		type = e_temp_type.CHARACTER
		shape_type = e_shape_type.CUBE
		light_type = e_tl_type.POINT_LIGHT
		
		// Preview window
		preview = new_obj(obj_preview)
		preview.space_trigger = true
		
		// Project lists
		project_lib_list = new_obj(obj_sortlist)
		project_lib_list.script = action_bench_project_select
		project_lib_list.height_percent = bench_list_percent
		project_lib_list.filter_type_list = temp_type_name_list
		
		project_res_list = new_obj(obj_sortlist)
		project_res_list.script = action_bench_project_select
		project_res_list.height_percent = bench_list_percent
		project_res_list.filter_type_list = res_type_name_list
		
		project_all_list = new_obj(obj_sortlist)
		project_all_list.script = action_bench_project_select
		project_all_list.height_percent = bench_list_percent
		project_all_list.filter_type_list = ds_list_create()

		for (var i = 0; i < ds_list_size(temp_type_name_list); i++)
			ds_list_add(project_all_list.filter_type_list, temp_type_name_list[|i])
		
		project_list = project_lib_list
		project_selected = null

		for (var i = 0; i < ds_list_size(res_type_name_list); i++)
		{
			var typename = res_type_name_list[|i];
			if (typename != "packunzipped" && typename != "legacyblocksheet" &&
				ds_list_find_index(project_all_list.filter_type_list, typename) < 0)
				ds_list_add(project_all_list.filter_type_list, typename)
		}

		sortlist_column_add(project_lib_list, "libname", 0)
		sortlist_column_add(project_lib_list, "libtype", 0.35)
		sortlist_column_add(project_lib_list, "libinstances", 0.65)
		sortlist_column_add(project_res_list, "projectname", 0)
		sortlist_column_add(project_res_list, "projecttype", 0.35)
		sortlist_column_add(project_res_list, "projectcount", 0.65)
		sortlist_column_add(project_all_list, "projectname", 0)
		sortlist_column_add(project_all_list, "projecttype", 0.35)
		sortlist_column_add(project_all_list, "projectcount", 0.65)
		
		// Character list
		char_list = new_obj(obj_sortlist)
		char_list.script = action_bench_model_name
		char_list.script_search = sortlist_search_model
		char_list.script_select_click = action_bench_create
		char_list.height_percent = bench_list_percent
		
		sortlist_column_add(char_list, "charname", 0)
		for (var c = 0; c < ds_list_size(mc_assets.char_list); c++)
			sortlist_add(char_list, mc_assets.char_list[|c].name)

		// Equipment list
		equipment_list = new_obj(obj_sortlist)
		equipment_list.script = action_bench_model_name
		equipment_list.script_search = sortlist_search_model
		equipment_list.script_select_click = action_bench_create
		equipment_list.header_show = false
		equipment_list.height_items = ds_list_size(mc_assets.equipment_list)
		
		sortlist_column_add(equipment_list, "spblockname", 0)
		for (var c = 0; c < ds_list_size(mc_assets.equipment_list); c++)
			sortlist_add(equipment_list, mc_assets.equipment_list[|c].name)
		
		// Model part list
		model_part_model_list = new_obj(obj_sortlist)
		model_part_model_list.script = action_bench_model_name
		model_part_model_list.script_search = sortlist_search_model
		model_part_model_list.script_select_click = action_bench_create
		model_part_model_list.height_percent = bench_list_percent
		
		sortlist_column_add(model_part_model_list, "modelpartmodelname", 0)
		for (var m = 0; m < ds_list_size(mc_assets.equipment_list); m++)
		{
			var model = mc_assets.equipment_list[|m];
			if (model.model_part_available)
				sortlist_add(model_part_model_list, model.name)
		}
		for (var m = 0; m < ds_list_size(mc_assets.char_list); m++)
		{
			var model = mc_assets.char_list[|m];
			if (model.model_part_available)
				sortlist_add(model_part_model_list, model.name)
		}
		for (var m = 0; m < ds_list_size(mc_assets.special_block_list); m++)
		{
			var model = mc_assets.special_block_list[|m];
			if (model.model_part_available)
				sortlist_add(model_part_model_list, model.name)
		}
		
		// Item list
		item_scroll = new_obj(obj_scrollbar)
			
		// Schematic list
		schematic_list = new_obj(obj_sortlist)
		schematic_list.script = action_bench_schematic_select
		schematic_list.script_select_click = action_bench_create
		schematic_list.header_show = false
		schematic_list.height_percent = 0.9
		
		sortlist_column_add(schematic_list, "schematicname", 0)
		
		schematic_list.column_sort = 0
		schematic_list.sort_asc = false
		schematic_selected = null
	
		// Block list
		block_list = new_obj(obj_sortlist)
		block_list.script = action_bench_block_name
		block_list.script_search = sortlist_search_block
		block_list.script_select_click = action_bench_create
		block_list.height_percent = bench_list_percent
		
		sortlist_column_add(block_list, "blockname", 0)
		for (var b = 0; b < ds_list_size(mc_assets.block_list); b++)
			if (!mc_assets.block_list[|b].timeline || mc_assets.block_list[|b].tl_model_name = "" || mc_assets.block_list[|b].model_double)
				sortlist_add(block_list, mc_assets.block_list[|b].name)
		
		// Special block list
		special_block_list = new_obj(obj_sortlist)
		special_block_list.script = action_bench_model_name
		special_block_list.script_search = sortlist_search_model
		special_block_list.script_select_click = action_bench_create
		special_block_list.height_percent = bench_list_percent
		
		sortlist_column_add(special_block_list, "spblockname", 0)
		for (var c = 0; c < ds_list_size(mc_assets.special_block_list); c++)
			sortlist_add(special_block_list, mc_assets.special_block_list[|c].name)
			
		// Sound lists
		sounds_list = new_obj(obj_soundlist)
		sounds_list.source = "sounds"
		sounds_list.script = action_bench_sound
		sounds_list.height_percent = bench_soundlist_percent
		
		music_list = new_obj(obj_soundlist)
		music_list.source = "music"
		music_list.script = action_bench_sound
		
		project_sounds_list = new_obj(obj_soundlist)
		project_sounds_list.source = "project"
		project_sounds_list.script = action_bench_sound
		
		sound = null
		sound_list_current = sounds_list
		audio_track = null
		music_res = null
		music_play_index = null
		music_note_next = 0
		music_history = ds_list_create()
		music_autoplay = false
		
		// Particles list
		particle_preset_list = new_obj(obj_sortlist)
		particle_preset_list.script = action_bench_particles_select
		particle_preset_list.header_show = false
		particle_preset_list.height_percent = bench_list_percent
		
		sortlist_column_add(particle_preset_list, "particlepresetname", 0)
		
		particle_preset_list.column_sort = 0
		particle_preset_list.sort_asc = false
		particle_preset_temp = null
		
		// Shape list
		shape_list = new_obj(obj_sortlist)
		shape_list.script = action_bench_shape_type
		shape_list.script_select_click = action_bench_create
		shape_list.header_show = false
		shape_list.height_items = e_shape_type.amount
		
		sortlist_column_add(shape_list, "shapename", 0)
		for (var i = 0; i < e_shape_type.amount; i++)
			sortlist_add(shape_list, i)
	}
}
