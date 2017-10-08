/// builder_event_create()
/// @desc Create event of the scenery builder handler.

build_size = vec3(0, 0, 0)
build_size_x = 0
build_size_y = 0
build_size_z = 0

build_pos = point3D(0, 0, 0)
build_pos_x = 0
build_pos_y = 0
build_pos_z = 0

build_edge[e_dir.amount] = false
build_edge_xp = false
build_edge_xn = false
build_edge_yp = false
build_edge_yn = false
build_edge_zp = false
build_edge_zn = false
build_edges = true

block_obj = array3D()
block_state_id = array3D()
block_state_id_current = 0
block_render_model = array3D()
block_render_model_is_multipart = array3D()
block_current = 0

block_tl_list = null
block_color = null
file_map = ""

/*build_size = vec3(0, 0, 0)
build_pos = point3D(0, 0, 0)
build_edge[e_dir.amount] = false
block_pos = point3D(0, 0, 0)
block_obj = array3D()
block_current = 0
block_state = array3D()
block_state_current = ""
block_render_models = array3D()
block_render_models_dir[e_dir.amount] = 0
block_tl_list = null

vars = ds_map_create()

// Create solid render model for culling edges
solid_model = new(obj_block_render_model)
with (solid_model)
{
	element_amount = 1
	element[0] = new(obj_block_render_element)
	with (element[0])
	{
		rot_from = point3D(0, 0, 0)
		rot_to = point3D(block_size, block_size, block_size)
		rotated = false
		for (var d = 0; d < e_dir.amount; d++)
		{
			rot_face_render[d] = true
			rot_face_depth[d] = e_block_depth.DEPTH0
		}
	}
}*/