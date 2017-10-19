/// builder_event_create()
/// @desc Create event of the scenery builder handler.

build_size = vec3(0, 0, 0)
build_size_x = 0
build_size_y = 0
build_size_z = 0
build_dsize = 0
build_xysize = 0

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

block_obj = ds_grid_create(1, 1)
block_state_id = ds_grid_create(1, 1)
block_state_id_current = 0
block_text = ds_grid_create(1, 1)
block_render_model = ds_grid_create(1, 1)
block_current = 0

block_tl_list = null
block_color = null
file_map = ""