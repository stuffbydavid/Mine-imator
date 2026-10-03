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
	bench_tab = e_bench_tab.CHARACTER
	bench_tab_list = list_new()
	list_edit = bench_tab_list
	list_edit.get_name = true
	list_edit.show_ticks = false
	
	list_item_add("type/project", e_bench_tab.PROJECT, "", null, icons.LIBRARY, null, bench_tab_select)
	list_item_add("type/character", e_bench_tab.CHARACTER, "", null, icons.CHARACTER, null, bench_tab_select)
	if (ds_list_size(mc_assets.equipment_list) > 0)
		list_item_add("type/equipment", e_bench_tab.EQUIPMENT, "", null, icons.SHIELD, null, bench_tab_select)
	list_item_add("type/model", e_bench_tab.MODEL, "", null, icons.MODEL, null, bench_tab_select)
	list_item_add("type/model_part", e_bench_tab.MODEL_PART, "", null, icons.PART, null, bench_tab_select)
	
	list_item_add("type/item", e_bench_tab.ITEM, "", null, icons.ITEM, null, bench_tab_select)
	list_item_add("type/world", e_bench_tab.WORLD, "", null, icons.SCENERY, null, bench_tab_select)
	list_item_add("type/schematic", e_bench_tab.SCHEMATIC, "", null, icons.HOUSE, null, bench_tab_select)
	list_item_add("type/block", e_bench_tab.BLOCK, "", null, icons.BLOCK, null, bench_tab_select)
	list_item_add("type/special_block", e_bench_tab.SPECIAL_BLOCK, "", null, icons.BLOCK_SPECIAL, null, bench_tab_select)
	
	list_item_add("type/camera", e_bench_tab.CAMERA, "", null, icons.CAMERA, null, bench_tab_select)
	list_item_add("type/sound", e_bench_tab.SOUND, "", null, icons.VOLUME, null, bench_tab_select)
	list_item_add("type/audio", e_bench_tab.AUDIO_TRACK, "", null, icons.NOTE, null, bench_tab_select)
	list_item_add("type/particles", e_bench_tab.PARTICLE_SPAWNER, "", null, icons.FIREWORKS, null, bench_tab_select)
	list_item_add("type/text", e_bench_tab.TEXT, "", null, icons.TEXT, null, bench_tab_select)
	
	list_item_add("type/camera_effect", e_bench_tab.CAMERA_EFFECT, "", null, icons.WAND, null, bench_tab_select)
	list_item_add("type/light_source", e_bench_tab.LIGHT_SOURCE, "", null, icons.LIGHT_POINT, null, bench_tab_select)
	list_item_add("type/path", e_bench_tab.PATH, "", null, icons.PATH, null, bench_tab_select)
	list_item_add("type/environment", e_bench_tab.ENVIRONMENT, "", null, icons.CLOUD, null, bench_tab_select)
	list_item_add("type/shape", e_bench_tab.SHAPE, "", null, icons.SHAPES, null, bench_tab_select)
	
	bench_advanced_tabs = [
		e_bench_tab.PROJECT,
		e_bench_tab.MODEL,
		e_bench_tab.AUDIO_TRACK,
		e_bench_tab.ENVIRONMENT
	]
	
	list_edit = null
	
	// Preview
	bench_tab_preview = [
		e_bench_tab.PROJECT,
		e_bench_tab.CHARACTER,
		e_bench_tab.EQUIPMENT,
		e_bench_tab.MODEL,
		e_bench_tab.MODEL_PART,
		e_bench_tab.ITEM,
		e_bench_tab.SCHEMATIC,
		e_bench_tab.BLOCK,
		e_bench_tab.SPECIAL_BLOCK,
		e_bench_tab.SHAPE,
		e_bench_tab.TEXT,
		e_bench_tab.SOUND,
		e_bench_tab.PARTICLE_SPAWNER
	]
	
	// Example
	bench_tab_example = [
		e_bench_tab.WORLD,
		e_bench_tab.CAMERA,
		e_bench_tab.AUDIO_TRACK,
		e_bench_tab.CAMERA_EFFECT,
		e_bench_tab.LIGHT_SOURCE,
		e_bench_tab.PATH,
		e_bench_tab.ENVIRONMENT
	]

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
		height_fixed = array_create(e_bench_tab.amount, 0)
		height_fixed_base = array_create(e_bench_tab.amount, 0)
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
		text_outline_color = c_text_outline
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
			if (typename != "pack_unzipped" && typename != "legacy_block_sheet" &&
				ds_list_find_index(project_all_list.filter_type_list, typename) < 0)
				ds_list_add(project_all_list.filter_type_list, typename)
		}

		sortlist_column_add(project_lib_list, "lib_name", 0)
		sortlist_column_add(project_lib_list, "lib_type", 0.35)
		sortlist_column_add(project_lib_list, "lib_instances", 0.65)
		sortlist_column_add(project_res_list, "project_name", 0)
		sortlist_column_add(project_res_list, "project_type", 0.35)
		sortlist_column_add(project_res_list, "project_count", 0.65)
		sortlist_column_add(project_all_list, "project_name", 0)
		sortlist_column_add(project_all_list, "project_type", 0.35)
		sortlist_column_add(project_all_list, "project_count", 0.65)
		
		// Character list
		char_list = new_obj(obj_sortlist)
		char_list.script = action_bench_model_name
		char_list.script_search = sortlist_search_model
		char_list.script_select_click = action_bench_create
		char_list.height_percent = bench_list_percent
		
		sortlist_column_add(char_list, "character_name", 0)
		
		for (var c = 0; c < ds_list_size(mc_assets.char_list); c++)
			sortlist_add(char_list, mc_assets.char_list[|c].name)

		// Equipment list
		equipment_list = new_obj(obj_sortlist)
		equipment_list.script = action_bench_model_name
		equipment_list.script_search = sortlist_search_model
		equipment_list.script_select_click = action_bench_create
		equipment_list.header_show = false
		equipment_list.height_items = ds_list_size(mc_assets.equipment_list)
		
		sortlist_column_add(equipment_list, "special_block_name", 0)
		
		for (var c = 0; c < ds_list_size(mc_assets.equipment_list); c++)
			sortlist_add(equipment_list, mc_assets.equipment_list[|c].name)
		
		// Model part list
		model_part_model_list = new_obj(obj_sortlist)
		model_part_model_list.script = action_bench_model_name
		model_part_model_list.script_search = sortlist_search_model
		model_part_model_list.script_select_click = action_bench_create
		model_part_model_list.height_percent = bench_list_percent
		
		sortlist_column_add(model_part_model_list, "model_part_model_name", 0)
		
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
		
		sortlist_column_add(schematic_list, "schematic_name", 0)
		
		schematic_list.column_sort = 0
		schematic_list.sort_asc = false
		schematic_selected = null
	
		// Block list
		block_list = new_obj(obj_sortlist)
		block_list.script = action_bench_block_name
		block_list.script_search = sortlist_search_block
		block_list.script_select_click = action_bench_create
		block_list.height_percent = bench_list_percent
		
		sortlist_column_add(block_list, "block_name", 0)
		
		for (var b = 0; b < ds_list_size(mc_assets.block_list); b++)
			if (!mc_assets.block_list[|b].timeline || mc_assets.block_list[|b].tl_model_name = "" || mc_assets.block_list[|b].model_double)
				sortlist_add(block_list, mc_assets.block_list[|b].name)
		
		// Special block list
		special_block_list = new_obj(obj_sortlist)
		special_block_list.script = action_bench_model_name
		special_block_list.script_search = sortlist_search_model
		special_block_list.script_select_click = action_bench_create
		special_block_list.height_percent = bench_list_percent
		
		sortlist_column_add(special_block_list, "special_block_name", 0)
		
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
		
		sortlist_column_add(particle_preset_list, "particle_preset_name", 0)
		
		particle_preset_list.column_sort = 0
		particle_preset_list.sort_asc = false
		particle_preset_temp = null
		
		// Camera effects
		camera_effect_type = e_cam_fx.FADE
		camera_effect_camera = app
		
		camera_effect_list_simple = new_obj(obj_sortlist)
		camera_effect_list_simple.script = action_bench_camera_effect
		camera_effect_list_simple.script_select_click = action_bench_create
		camera_effect_list_simple.header_show = false
		
		camera_effect_list_advanced = new_obj(obj_sortlist)
		camera_effect_list_advanced.script = action_bench_camera_effect
		camera_effect_list_advanced.script_select_click = action_bench_create
		camera_effect_list_advanced.header_show = false
		
		sortlist_column_add(camera_effect_list_simple, "camera_effect_name", 0)
		sortlist_column_add(camera_effect_list_advanced, "camera_effect_name", 0)
			
		for (var c = 0; c < e_cam_fx.amount; c++)
		{
			if (c <= e_cam_fx.LENS_DIRT)
				sortlist_add(camera_effect_list_simple, c)
			sortlist_add(camera_effect_list_advanced, c)
		}
		
		camera_effect_list_simple.height_items = ds_list_size(camera_effect_list_simple.list)
		camera_effect_list_advanced.height_items = ds_list_size(camera_effect_list_advanced.list)
			
		// Shape list
		shape_list = new_obj(obj_sortlist)
		shape_list.script = action_bench_shape_type
		shape_list.script_select_click = action_bench_create
		shape_list.header_show = false
		shape_list.height_items = e_shape_type.amount
		
		sortlist_column_add(shape_list, "shape_name", 0)
		
		for (var i = 0; i < e_shape_type.amount; i++)
			sortlist_add(shape_list, i)
	}
}
