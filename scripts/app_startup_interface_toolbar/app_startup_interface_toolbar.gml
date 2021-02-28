/// app_startup_interface_toolbar()

toolbar_location = setting_toolbar_location
toolbar_size = setting_toolbar_size

toolbar_rows = 0
toolbar_resize_size = 0

// Workbench
bench_open = false
bench_hover_ani = 0
bench_click_ani = 0
bench_show_ani_type = ""
bench_show_ani = 0
bench_width = 410
bench_height = 325

bench_type_list = list_new()
bench_type_list.get_name = true
list_edit = bench_type_list

list_item_add("typechar", e_tl_type.CHARACTER, "", null, icons.TL_CHARACTER, null, bench_click)
list_item_add("typebodypart", e_tl_type.BODYPART, "", null, icons.TL_BODYPART, null, bench_click)
list_item_add("typemodel", e_tl_type.MODEL, "", null, icons.TL_MODEL, null, bench_click)

list_item_add("typeitem", e_tl_type.ITEM, "", null, icons.TL_ITEM, null, bench_click)
list_item_add("typescenery", e_tl_type.SCENERY, "", null, icons.TL_SCENERY, null, bench_click)
list_item_add("typeblock", e_tl_type.BLOCK, "", null, icons.TL_BLOCK, null, bench_click)
list_item_add("typespblock", e_tl_type.SPECIAL_BLOCK, "", null, icons.TL_SPECIAL_BLOCK, null, bench_click)

list_item_add("typeshape", e_tl_type.SHAPE, "", null, icons.SHAPES, null, bench_click)
list_item_add("typetext", e_tl_type.TEXT, "", null, icons.TL_TEXT, null, bench_click)

list_item_add("typecamera", e_tl_type.CAMERA, "", null, icons.TL_CAMERA, null, bench_click)
list_item_add("typeparticles", e_tl_type.PARTICLE_SPAWNER, "", null, icons.FIREWORKS, null, bench_click)
list_item_add("typelightsource", e_tl_type.LIGHT_SOURCE, "", null, icons.TL_POINT_LIGHT, null, bench_click)
list_item_add("typeaudio", e_tl_type.AUDIO, "", null, icons.TL_AUDIO, null, bench_click)

list_edit = null

/*
bench_type_list = ds_list_create()
ds_list_add(bench_type_list,
	e_tl_type.CHARACTER,
	e_tl_type.SCENERY,
	e_tl_type.ITEM,
	e_tl_type.BLOCK,
	e_tl_type.SPECIAL_BLOCK,
	e_tl_type.BODYPART,
	e_tl_type.PARTICLE_SPAWNER,
	e_tl_type.POINT_LIGHT,
	e_tl_type.SPOT_LIGHT,
	e_tl_type.TEXT,
	e_tl_type.CUBE,
	e_tl_type.SPHERE,
	e_tl_type.CONE,
	e_tl_type.CYLINDER,
	e_tl_type.SURFACE,
	e_tl_type.CAMERA,
	e_tl_type.BACKGROUND,
	e_tl_type.AUDIO,
	e_tl_type.MODEL
)
*/

// Workbench settings
bench_settings = new(obj_bench_settings)
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
	item_tex = mc_res
	block_tex = mc_res
	text_font = mc_res
	particle_preset = ""
	type = e_temp_type.CHARACTER
	shape_type = e_shape_type.SURFACE
	light_type = e_tl_type.POINT_LIGHT
	
	// Preview window
	preview = new(obj_preview)
	
	// Character list
	char_list = new(obj_sortlist)
	char_list.script = action_bench_model_name
	sortlist_column_add(char_list, "charname", 0)
	for (var c = 0; c < ds_list_size(mc_assets.char_list); c++)
		sortlist_add(char_list, mc_assets.char_list[|c].name)
	
	// Item list
	item_scroll = new(obj_scrollbar)

	// Block list
	block_list = new(obj_sortlist)
	block_list.script = action_bench_block_name
	sortlist_column_add(block_list, "blockname", 0)
	for (var b = 0; b < ds_list_size(mc_assets.block_list); b++)
		if (!mc_assets.block_list[|b].timeline || mc_assets.block_list[|b].tl_model_name = "" || mc_assets.block_list[|b].model_double)
			sortlist_add(block_list, mc_assets.block_list[|b].name)
	block_tbx_data = new_textbox_integer()

	// Special block list
	special_block_list = new(obj_sortlist)
	special_block_list.script = action_bench_model_name
	sortlist_column_add(special_block_list, "spblockname", 0)
	for (var c = 0; c < ds_list_size(mc_assets.special_block_list); c++)
		sortlist_add(special_block_list, mc_assets.special_block_list[|c].name)
	
	// Bodypart list
	bodypart_model_list = new(obj_sortlist)
	bodypart_model_list.script = action_bench_model_name
	sortlist_column_add(bodypart_model_list, "bodypartmodelname", 0)
	for (var m = 0; m < ds_list_size(mc_assets.char_list); m++)
		sortlist_add(bodypart_model_list, mc_assets.char_list[|m].name)
	for (var m = 0; m < ds_list_size(mc_assets.special_block_list); m++)
		sortlist_add(bodypart_model_list, mc_assets.special_block_list[|m].name)
	
	// Particles list
	particles_list = new(obj_sortlist)
	particles_list.script = action_bench_particles
	sortlist_column_add(particles_list, "particlepresetname", 0)
}
