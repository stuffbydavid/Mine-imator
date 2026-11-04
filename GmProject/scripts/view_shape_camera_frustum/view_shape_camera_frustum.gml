/// @desc Renders an outline of a camera's frustum.
/// @arg timeline

function view_shape_camera_frustum(tl)
{
	if (tl.value[e_value.CAM_FOV] % 180 = 0)
		return 0
	
	var tempmat, mat, ratio, fovtan, effects;
	tempmat = tl.matrix
	with (tl)
		effects = tl_camera_effects_get()
	
	// Camera shake
	if (effects != null && tl.camera_effect_enabled[e_cam_fx.SHAKE])
	{
		var shake = vec3(
			simplex1d_lib((app.timeline_marker/app.project_tempo) * effects[e_value.CAM_FX_SHAKE_SPEED_X]) * effects[e_value.CAM_FX_SHAKE_STRENGTH_X],
			simplex2d_lib((app.timeline_marker/app.project_tempo) * effects[e_value.CAM_FX_SHAKE_SPEED_Y], 1000) * effects[e_value.CAM_FX_SHAKE_STRENGTH_Y],
			simplex2d_lib((app.timeline_marker/app.project_tempo) * effects[e_value.CAM_FX_SHAKE_SPEED_Z], 2000) * effects[e_value.CAM_FX_SHAKE_STRENGTH_Z]
		);
	
		// Create matrix
		var shakemat;
		if (effects[e_value.CAM_FX_SHAKE_MODE])
			shakemat = matrix_create(shake, vec3(0), vec3(1))
		else
			shakemat = matrix_create(vec3(0), shake, vec3(1))
		
		tempmat = matrix_multiply(shakemat, tempmat)
	}
	
	// Convert matrix to world space
	mat = array_copy_1d(tempmat)
	matrix_remove_scale(mat)
	
	ratio = (tl.value[e_value.CAM_WIDTH] / tl.value[e_value.CAM_HEIGHT])
	fovtan = tan(degtorad(tl.value[e_value.CAM_FOV] * 0.5)) // Multiply this by distance
		
	// DOF visualizer
	if (effects != null && tl.camera_effect_enabled[e_cam_fx.DOF])
		view_shape_camera_frustum_dof(effects, mat, ratio, fovtan)
			
	var viewfrustumpoints = [
		point3D(-((fovtan * cam_near) * ratio), cam_near, -fovtan * cam_near), // nbr
		point3D(-((fovtan * cam_near) * ratio), cam_near, fovtan * cam_near), // ntr
		point3D(((fovtan * cam_near) * ratio), cam_near, -fovtan * cam_near), // nbl
		point3D(((fovtan * cam_near) * ratio), cam_near, fovtan * cam_near), // ntl
		point3D(-((fovtan * cam_far) * ratio), cam_far, -fovtan * cam_far), // fbr
		point3D(-((fovtan * cam_far) * ratio), cam_far, fovtan * cam_far), // ftr
		point3D(((fovtan * cam_far) * ratio), cam_far, -fovtan * cam_far), // fbl
		point3D(((fovtan * cam_far) * ratio), cam_far, fovtan * cam_far) // ftl
	];
	
	// Frustum outline
	draw_set_color(c_control_red)
	//draw_set_alpha(.5)
	
	view_shape_draw(viewfrustumpoints, mat)
	
	draw_set_color(c_white)
	//draw_set_alpha(1)
}
