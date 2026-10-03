function render_set_projection(from, to, up, fov, aspect, znear, zfar)
{
	var mv = matrix_create_lookat(from, to, up);
	var mp = matrix_build_projection_perspective_fov(-fov, -aspect, znear, zfar);
	
	camera_set_view_mat(cam_render, mv)
	camera_set_proj_mat(cam_render, mp)
	camera_apply(cam_render)
}
