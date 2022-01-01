/// render_world_start([zfar])
/// @arg [zfar]

function render_world_start(zfar)
{
	if (zfar != undefined)
		cam_far = min(cam_far_prev, cam_near + zfar)
	else
		cam_far = cam_far_prev
	
	gpu_set_ztestenable(true)
	gpu_set_zwriteenable(true)
	render_set_projection(cam_from, cam_to, cam_up, cam_fov, render_ratio, cam_near, cam_far)
	
	proj_from = cam_from
	render_proj_from = proj_from
	proj_matrix = matrix_get(matrix_projection)
	view_matrix = matrix_get(matrix_view)
	view_proj_matrix = matrix_multiply(view_matrix, proj_matrix)
	
	render_frustum.build(view_proj_matrix)
	render_frustum.active = true
	
	proj_depth_near = cam_near
	proj_depth_far = cam_far
}
