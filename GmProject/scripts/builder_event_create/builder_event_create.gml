/// @desc Create event of the scenery builder handler.

function builder_event_create()
{
	builder_thread_event_create()
	
	sch_palette_blocks = null
	sch_palette_state_ids = null
	sch_palette_waterlogged = null
	sch_blockdata_array = null
	sch_blockdata_ints = false
	sch_legacy_blocks_array = null
	sch_legacy_data_array = null
	sch_timeline_amount = 0
	sch_tileentity_list = null
	
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
	file_map = ""

	thread_list = ds_list_create()
}
