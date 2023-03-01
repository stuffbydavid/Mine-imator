/// render_set_projection(from, to, up, fov, aspect, znear, zfar)
/// @arg from
/// @arg to
/// @arg up
/// @arg fov
/// @arg aspect
/// @arg znear
/// @arg zfar

function render_set_projection(from, to, up, fov, aspect, znear, zfar)
{
	var mV = matrix_create_lookat(from, to, up);
	var mP = matrix_build_projection_perspective_fov(-fov, -aspect, znear, zfar);
	
	camera_set_view_mat(cam_render, mV)
	camera_set_proj_mat(cam_render, mP)
	camera_apply(cam_render)
}
