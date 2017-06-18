/// render_set_projection_ortho(x, y, width, height, angle)
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg angle

var xx = argument0;
var yy = argument1;
var ww = argument2;
var hh = argument3;
var angle = argument4;

var mV = matrix_build_lookat(xx + ww / 2, yy + hh / 2, -16000, 
							 xx + ww / 2, yy + hh / 2, 0,
							 dsin(-angle), dcos(-angle), 0)
var mP = matrix_build_projection_ortho(ww, hh, 1, 32000)

camera_set_view_mat(cam_render, mV)
camera_set_proj_mat(cam_render, mP)
camera_apply(cam_render)