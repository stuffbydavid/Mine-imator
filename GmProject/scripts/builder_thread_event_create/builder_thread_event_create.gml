function builder_thread_event_create()
{
	threadid = 0
	
	build_size_x = 0
	build_size_y = 0
	build_size_z = 0
	build_size_total = 0
	build_size_sqrt = 0
	
	build_pos = 0
	build_pos_x = 0
	build_pos_y = 0
	build_pos_z = 0
	
	build_edge_xp = false
	build_edge_xn = false
	build_edge_yp = false
	build_edge_yn = false
	build_edge_zp = false
	build_edge_zn = false
	
	builder_scenery = false
	builder_scenery_legacy = false
	
	block_pos_x = 0
	block_pos_y = 0
	block_pos_z = 0
	block_color = null
	block_face_min_depth_xp = null
	block_face_min_depth_xn = null
	block_face_min_depth_yp = null
	block_face_min_depth_yn = null
	block_face_min_depth_zp = null
	block_face_min_depth_zn = null
	
	block_obj = null
	block_waterlogged = null
	block_current = 0
	block_state_id = null
	block_state_id_current = 0
	block_render_model = null
	block_render_model_multipart_map = null
	
	block_tl_map = null
	
	block_vbuffer_current = null
	block_vertex_wave = e_vertex_wave.NONE
	block_vertex_wave_zmin = null
	block_vertex_wave_zmax = null
	block_vertex_emissive = 0
	block_vertex_subsurface = 0
	block_vertex_rgb = c_white
	block_vertex_alpha = 1
}