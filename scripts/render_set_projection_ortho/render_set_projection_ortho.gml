/// render_set_projection_ortho(x, y, width, height, angle)
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg angle

function render_set_projection_ortho(xx, yy, ww, hh, angle)
{
	var mV = matrix_build_lookat(xx + ww / 2, yy + hh / 2, -16000, 
								 xx + ww / 2, yy + hh / 2, 0,
								 dsin(-angle), dcos(-angle), 0)
	var mP = matrix_build_projection_ortho(ww, hh, 1, 32000)
	
	camera_set_view_mat(cam_render, mV)
	camera_set_proj_mat(cam_render, mP)
	camera_apply(cam_render)
}
