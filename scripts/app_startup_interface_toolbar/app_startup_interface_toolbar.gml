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
bench_width = 490
bench_height = 250

bench_type_list = ds_list_create()
ds_list_add(bench_type_list,
	"char",
	"scenery",
	"item",
	"block",
	"spblock",
	"camera",
	"bodypart",
	"particles",
	"pointlight",
	"spotlight",
	"text",
	"background",
	"cube",
	"sphere",
	"cone",
	"cylinder",
	"surface",
	"audio"
)

// Workbench settings
bench_settings = new(obj_bench_settings)
with (bench_settings)
{
	// Size
	width = 0
	width_goal = 0
	height = 0
	height_goal = app.bench_height
	width_custom = 0
	height_custom = 0

	// Default settings
	temp_event_create()
	model_name = "human"
	model_state = array_copy_1d(mc_assets.model_name_map[?model_name].default_state)
	model_part_name = "head"
	temp_update_model()
	temp_update_model_part()
	block_state = array_copy_1d(mc_assets.block_name_map[?block_name].default_state)
	temp_particles_init()
	skin = mc_res
	item_tex = mc_res
	block_tex = mc_res
	text_font = mc_res
	particle_preset = ""
	
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
		if (!mc_assets.block_list[|b].timeline || mc_assets.block_list[|b].tl_model_name = "")
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
