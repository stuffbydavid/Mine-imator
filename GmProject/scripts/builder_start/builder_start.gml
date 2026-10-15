function builder_start()
{
	build_pos_index = 0
	build_size_xy = build_size[X] * build_size[Y]
	build_size_total = build_size_xy * build_size[Z]
	build_edges = !(app.setting_scenery_remove_edges && (build_size[X] > scenery_large_threshold && build_size[Y] > scenery_large_threshold) && build_single_block = null)
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
	ds_map_clear(block_decorated_pot_sherds_map)
	
	builder_create_buffers()
}
