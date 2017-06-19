/// app_startup_interface_toolbar()

toolbar_location = "top"
toolbar_size = 82

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

bench_list = ds_list_create()
ds_list_add(bench_list,
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
	iid = 0
	temp_init()
	temp_particles_init()
	char_model = mc_version.char_model_map[?"human.mimodel"]
	char_skin = res_def
	item_tex = res_def
	block_tex = res_def
	text_font = res_def
	particle_preset = ""
	
	// Preview window
	preview = new(obj_preview)

	// Character list
	char_list = new(obj_sortlist)
	char_list.script = action_bench_char_model
	sortlist_column_add(char_list, "charname", 0)
	for (var c = 0; c < ds_list_size(mc_version.char_list); c++)
		sortlist_add(char_list, mc_version.char_model_map[?mc_version.char_list[|c]])
	
	// Item list
	item_scroll = new(obj_scrollbar)

	// Block list
	block_list = new(obj_sortlist)
	block_list.script = action_bench_block_id
	sortlist_column_add(block_list, "blockid", 0)
	sortlist_column_add(block_list, "blockname", 0.25)
	for (var b = 0; b < 256; b++) // TODO
		if (!is_undefined(mc_version.block_map[?b]))
			sortlist_add(block_list, b)
	block_tbx_data = new_textbox_integer()

	// Special block list
	spblock_list = new(obj_sortlist)
	spblock_list.script = action_bench_char_model
	sortlist_column_add(spblock_list, "spblockname", 0)
	//for (var p = characters; p < characters + characters_blocks; p++)
	//	sortlist_add(spblock_list, iget(obj_model, p))
	
	// Bodypart list
	bodypart_char_list = new(obj_sortlist)
	bodypart_char_list.script = action_bench_char_model
	sortlist_column_add(bodypart_char_list, "bodypartcharname", 0)
	//for (var m = 0; m < characters + characters_blocks; m++)
	//	sortlist_add(bodypart_char_list, iget(obj_model, m))
	
	// Particles list
	particles_list = new(obj_sortlist)
	particles_list.script = action_bench_particles
	sortlist_column_add(particles_list, "particlepresetname", 0)
}
