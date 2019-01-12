/// builder_event_create()
/// @desc Create event of the scenery builder handler.

build_size = vec3(0, 0, 0)
build_size_x = 0
build_size_y = 0
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

block_obj = null
block_waterlogged = null
block_current = 0
block_state_id = null
block_state_id_current = 0
block_render_model = null
block_text_map = ds_map_create()

block_banner_color_map = ds_map_create()
block_banner_patterns_map = ds_map_create()
block_banner_pattern_colors_map = ds_map_create()

block_tl_add = false
block_tl_list = null
block_color = null
file_map = ""