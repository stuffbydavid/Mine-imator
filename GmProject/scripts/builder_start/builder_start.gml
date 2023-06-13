/// builder_start()

function builder_start()
{
	build_pos = 0
	build_size_xy = build_size_x * build_size_y
	build_size_total = build_size_xy * build_size_z
	build_edges = !(app.setting_scenery_remove_edges && (build_size_x > 300 && build_size_y > 300) && build_single_block == null)
	block_tl_add = false
	block_multithreaded_skip = false
	
	ds_map_clear(block_text_front_map)
	ds_map_clear(block_text_front_color_map)
	ds_map_clear(block_text_front_glow_color_map)
	ds_map_clear(block_text_front_glowing_map)
	ds_map_clear(block_text_back_map)
	ds_map_clear(block_text_back_color_map)
	ds_map_clear(block_text_back_glowing_map)
	ds_map_clear(block_banner_color_map)
	ds_map_clear(block_banner_patterns_map)
	ds_map_clear(block_banner_pattern_colors_map)
	ds_map_clear(block_skull_map)
	ds_map_clear(block_skull_res_map)
	ds_map_clear(block_skull_texture_map)
	
	builder_create_buffers()
}
