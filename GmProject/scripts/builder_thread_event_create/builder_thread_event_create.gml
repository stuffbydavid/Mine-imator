/// CppGen array<int> build_size
/// CppGen array<int> build_min_pos
/// CppGen array<int> build_max_pos
/// CppGen int build_size_xy
/// CppGen int build_size_total
/// CppGen int build_single_stateid
/// CppGen int build_pos_index
/// CppGen array<int> build_pos
/// CppGen array<int> build_neighbor
/// CppGen array<bool> build_edge
/// CppGen array<bool> block_face_full
/// CppGen array<int> block_face_min_depth
/// CppGen array<real> block_model_pos
/// CppGen bool block_model_double
/// CppGen array<bool> liquid_match
/// CppGen array<bool> liquid_solid
/// CppGen array<int> liquid_waterlogged
/// CppGen array<real> liquid_side_level
/// CppGen array<real> liquid_side_height
/// CppGen array<real> liquid_flow
/// CppGen array<real> liquid_corner_level
/// CppGen array<real> liquid_corner_height
/// CppGen array<real> liquid_top_mid_uv
/// CppGen array<real> liquid_slot_still_pos
/// CppGen array<real> liquid_slot_flow_pos
/// CppGen array<real> liquid_slot_size
/// CppGen array<real> liquid_from
/// CppGen array<real> liquid_to
/// CppGen array<real> liquid_mid
	
function builder_thread_event_create()
{
	threadid = 0
	
	build_size = vec3(0)
	build_min_pos = vec3(0)
	build_max_pos = vec3(0)
	build_size_xy = 0
	build_size_total = 0
	
	build_randomize = false
	build_transform = false
	build_edges = true
	build_edit = false
	build_remove = false
	
	build_single_block = null
	build_single_stateid = 0
	build_multithreaded = null
	
	build_pos_index = 0
	build_pos = vec3(0)
	build_neighbor = vec3(0)
	
	build_edge = array_create(block_faces, false)
	
	block_face_full = array_create(block_faces, false)
	block_face_min_depth = array_create(block_faces, null)
	block_face_min = array_create(block_faces, null)
	block_face_max = array_create(block_faces, null)

	block_model_pos = vec3(0)
	block_model_double = false
	
	liquid_match = array_create(block_faces, false)
	liquid_solid = array_create(block_faces, false)
	liquid_waterlogged = array_create(block_faces, -1)
	liquid_side_level = array_create(4, 0)
	liquid_side_height = array_create(4, 0)
	liquid_flow = array_create(4, 0)
	liquid_corner_level = array_create(4, 0)
	liquid_corner_height = array_create(4, 0)
	liquid_corner_direction = [ vec2(XN, YN), vec2(XP, YN), vec2(XP, YP), vec2(XN, YP) ]
	liquid_side_corner = [ vec2(2, 1), vec2(0, 3), vec2(3, 2), vec2(1, 0) ]
	liquid_top_mid_uv = vec2(0)
	liquid_slot_still_pos = vec2(0)
	liquid_slot_flow_pos = vec2(0)
	liquid_slot_size = vec2(0)
	liquid_from = vec3(0)
	liquid_to = vec3(0)
	liquid_mid = vec3(0)
	
	for (var c = 0; c < 4; c++)
	{
		liquid_corner_pos[c] = vec3(0)
		liquid_side_pos[c] = vec3(0)
		liquid_bottom_pos[c] = vec3(0)
		liquid_side_uv[c] = vec2(0)
		liquid_corner_left_uv[c] = vec2(0)
		liquid_corner_right_uv[c] = vec2(0)
		liquid_top_uv[c] = vec2(0)
	}

	block_obj = null
	block_waterlogged = null
	block_current = null
	block_state_id = null
	block_state_id_current = 0
	block_color_index = 0

	block_render_model = []
	block_render_model_multipart_map = null

	block_tl_map = null
	
	block_vbuffer_current = null
	block_meshes = []
	block_mesh = null
	block_meshes_num = vec3(1)
	block_vertex_wave = e_vertex_wave.NONE
	block_vertex_wave_zmin = null
	block_vertex_wave_zmax = null
	block_vertex_emissive = 0
	block_vertex_subsurface = 0
	block_vertex_color_index = 0

	builder_scenery = false
	builder_scenery_legacy = false
}
