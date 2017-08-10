/// builder_event_create()
/// @desc Create event of the scenery builder handler.

build_size = vec3(0, 0, 0)
build_pos = point3D(0, 0, 0)
build_edge[e_dir.amount] = false
block_color = null
file_map = ""

block_pos = point3D(0, 0, 0)
block_name[0] = 0
block_name_current = 0
block_state[0] = 0
block_state_current = 0
block_render_models[0] = 0
block_render_models_dir[e_dir.amount] = 0

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
}