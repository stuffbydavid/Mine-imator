/// @desc Returns the nearest scene intersection for a view pixel.
/// @arg view
/// @arg x
/// @arg y
/// @arg [placing]
/// @arg [build]

function view_raycast(view, xx, yy, placing = false, build = false)
{
	// Unproject near and far points, supporting perspective and orthographic views
	var tx, ty, nearpos, farpos, viewray, origin, endpoint, dir, dis, result;
	tx = xx / view.surface_width * 2 - 1
	ty = 1 - yy / view.surface_height * 2
	nearpos = vec4_homogenize(vec4_mul_matrix(vec4(tx, ty, 0, 1), view.surface_proj_matrix_inverse))
	farpos = vec4_homogenize(vec4_mul_matrix(vec4(tx, ty, 0.5, 1), view.surface_proj_matrix_inverse))
	viewray = vec3_sub(farpos, nearpos)
	farpos = vec3_add(nearpos, vec3_mul(viewray, (view.surface_cam_far - nearpos[Z]) / viewray[Z]))
	nearpos = vec3_add(nearpos, vec3_mul(viewray, (view.surface_cam_near - nearpos[Z]) / viewray[Z]))
	origin = point3D_mul_matrix(nearpos, view.surface_view_matrix_inverse)
	endpoint = point3D_mul_matrix(farpos, view.surface_view_matrix_inverse)
	dir = vec3_sub(endpoint, origin)
	dis = vec3_length(dir)
	dir = vec3_normalize(dir)

	if (placing)
		dis = min(dis, build ? build_far : place_far)

	result = world_raycast(view, origin, dir, dis, placing, build)

	// DOF uses camera-space depth rather than distance along the mouse ray
	if (!placing)
	{
		var viewpos = point3D_mul_matrix(result[e_raycast.POSITION], view.surface_view_matrix);
		result[@e_raycast.DEPTH] = viewpos[Z]
	}

	return result
}
