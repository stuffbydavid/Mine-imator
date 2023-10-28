/// builder_event_create()
/// @desc Create event of the scenery builder handler.

function builder_event_create()
{
	sch_palette_blocks = null
	sch_palette_stateids = null
	sch_palette_waterlogged = null
	sch_blockdata_array = null
	sch_blockdata_ints = false
	sch_legacy_blocksarray = null
	sch_legacy_dataarray = null
	sch_timeline_amount = 0
	sch_tileentity_list = null
	
	build_size = vec3(0, 0, 0)
	build_size_x = 0
	build_size_y = 0
	build_size_xy = 0
	build_size_z = 0
	build_size_total = 0
	build_size_sqrt = 0
	
	build_pos_x = 0
	build_pos_y = 0
	build_pos_z = 0
	
	build_edge_xp = false
	build_edge_xn = false
	build_edge_yp = false
	build_edge_yn = false
	build_edge_zp = false
	build_edge_zn = false
	build_edges = true
	build_single_block = null
	build_single_stateid = 0
	build_multithreaded = null
	build_randomize = false
	
	block_obj = null
	block_waterlogged = null
	block_current = 0
	block_state_id = null
	block_state_id_current = 0
	block_render_model = null
	block_text_front_map = ds_map_create()
	block_text_front_color_map = ds_map_create()
	block_text_front_glow_color_map = ds_map_create()
	block_text_front_glowing_map = ds_map_create()
	block_text_back_map = ds_map_create()
	block_text_back_color_map = ds_map_create()
	block_text_back_glow_color_map = ds_map_create()
	block_text_back_glowing_map = ds_map_create()
	
	block_banner_color_map = ds_map_create()
	block_banner_patterns_map = ds_map_create()
	block_banner_pattern_colors_map = ds_map_create()
	
	block_skull_map = ds_map_create()
	block_skull_res_map = ds_map_create()
	block_skull_texture_map = ds_map_create()
	block_skull_texture_fail = false
	block_skull_texture_name = ""
	block_skull_texture = null
	block_skull_download_time = 0
	block_skull_download_wait = false
	
	block_skull_texture_count = 0
	block_skull_finish_count = 0
	block_skull_fail_count = 0
	
	block_decorated_pot_sherds_map = ds_map_create()
	
	block_multithreaded_skip = false
	block_tl_add = false
	block_tl_list = null
	block_color = null
	file_map = ""
	
	builder_scenery = false
	builder_scenery_legacy = false

	thread_list = ds_list_create()
}
