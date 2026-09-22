/// app_startup_interface_build()

function app_startup_interface_build()
{
	build_type = e_tl_type.BLOCK
	build_structure = null
	
	build_box = null
	build_box_top = null
	build_box_render = null
	build_box_matrix = MAT_IDENTITY
	
	var boxsize, boxmesh, topmesh;
	boxsize = block_half_size * 1.0025
	boxmesh = [
		[
			point3D(-boxsize, -boxsize, -boxsize),
			point3D( boxsize, -boxsize, -boxsize),
			point3D( boxsize,  boxsize, -boxsize),
			point3D(-boxsize,  boxsize, -boxsize),
			point3D(-boxsize, -boxsize,  boxsize),
			point3D( boxsize, -boxsize,  boxsize),
			point3D( boxsize,  boxsize,  boxsize),
			point3D(-boxsize,  boxsize,  boxsize)
		],
		[0, 1, 1, 2, 2, 3, 3, 0, 0, 4, 1, 5, 2, 6, 3, 7, 4, 5, 5, 6, 6, 7, 7, 4]
	]
	topmesh = [
		[
			point3D(-boxsize, -boxsize, boxsize),
			point3D( boxsize, -boxsize, boxsize),
			point3D( boxsize,  boxsize, boxsize),
			point3D(-boxsize,  boxsize, boxsize)
		],
		[0, 1, 1, 2, 2, 3, 3, 0]
	]
	
	for (var m = 0; m < 2; m++)
	{
		var mesh = m = 0 ? boxmesh : topmesh;
		var points = mesh[0];
		var edges = mesh[1];
		
		vbuffer_current = vertex_create_buffer()
		vertex_begin(vbuffer_current, vertex_format)
		
		for (var i = 0; i < array_length(edges); i += 2)
		{
			var a = points[edges[i]];
			var b = points[edges[i + 1]];
			var dir = vec3_sub(b, a);
			vertex_add(a, dir, [0, 0])
			vertex_add(b, dir, [1, 0])
			vertex_add(a, dir, [0, 1])
			vertex_add(b, dir, [1, 0])
			vertex_add(b, dir, [1, 1])
			vertex_add(a, dir, [0, 1])
		}
		
		vertex_end(vbuffer_current)
		vertex_freeze(vbuffer_current)
		
		if (m = 0)
			build_box = vbuffer_current
		else
			build_box_top = vbuffer_current
	}

	// Build settings
	build_settings = new_obj(obj_build_settings)
	with (build_settings)
	{
		temp_event_create()
		
		temp = id
		type = e_temp_type.BLOCK
		block_state = array_copy_1d(mc_assets.block_name_map[?block_name].default_state)
		
		temp_update_rot_point()
		preview = null
	}
}
