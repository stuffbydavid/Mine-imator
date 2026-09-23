/// view_shape_camera_frustum(timeline)
/// @arg timeline
/// @desc Renders an outline of a camera's frustum.

function view_shape_camera_frustum(tl)
{
	if (tl.value[e_value.CAM_FOV] % 180 = 0)
		return 0
	
	var tempmat = tl.matrix;
	
	// Camera shake
	if (tl.value[e_value.CAM_SHAKE])
	{
		var shake = vec3(
			simplex_lib((app.timeline_marker/app.project_tempo) * tl.value[e_value.CAM_SHAKE_SPEED_X]) * tl.value[e_value.CAM_SHAKE_STRENGTH_X],
			simplex_lib((app.timeline_marker/app.project_tempo) * tl.value[e_value.CAM_SHAKE_SPEED_Y], 1000) * tl.value[e_value.CAM_SHAKE_STRENGTH_Y],
			simplex_lib((app.timeline_marker/app.project_tempo) * tl.value[e_value.CAM_SHAKE_SPEED_Z], 2000) * tl.value[e_value.CAM_SHAKE_STRENGTH_Z],
		);
	
		// Create matrix
		var shakemat;
		if (tl.value[e_value.CAM_SHAKE_MODE])
			shakemat = matrix_create(shake, vec3(0), vec3(1))
		else
			shakemat = matrix_create(vec3(0), shake, vec3(1))
		
		tempmat = matrix_multiply(shakemat, tempmat)
	}
	// Convert matrix to world space
	var mat = array_copy_1d(tempmat);
	matrix_remove_scale(mat)
	
	var ratio, sizemath;
	ratio = (tl.value[e_value.CAM_WIDTH] / tl.value[e_value.CAM_HEIGHT])
	sizemath = tan(degtorad(tl.value[e_value.CAM_FOV] * 0.5)) // Multiply this by distance
		
	// DOF visualizer
	if (tl.value[e_value.CAM_DOF])
		view_shape_camera_frustum_dof(tl, mat, ratio, sizemath)
			
	var viewfrustumpoints = array(
		point3D(-((sizemath * cam_near) * ratio), cam_near, -sizemath * cam_near), //nbr
		point3D(-((sizemath * cam_near) * ratio), cam_near, sizemath * cam_near), //ntr
		point3D(((sizemath * cam_near) * ratio), cam_near, -sizemath * cam_near), //nbl
		point3D(((sizemath * cam_near) * ratio), cam_near, sizemath * cam_near), //ntl
		point3D(-((sizemath * cam_far) * ratio), cam_far, -sizemath * cam_far), //fbr
		point3D(-((sizemath * cam_far) * ratio), cam_far, sizemath * cam_far), //ftr
		point3D(((sizemath * cam_far) * ratio), cam_far, -sizemath * cam_far), //fbl
		point3D(((sizemath * cam_far) * ratio), cam_far, sizemath * cam_far) //ftl
	)
	
	// Frustum outline
	draw_set_color(c_control_red)
	//draw_set_alpha(.5)
	
	view_shape_draw(viewfrustumpoints, mat)
	
	draw_set_color(c_white)
	//draw_set_alpha(1)
}

function view_shape_camera_frustum_dof(tl, mat, ratio, sizemath)
{
	var dofnear, doffar, dofblurnear, dofblurfar;
	dofnear = min(cam_far, max(cam_near, tl.value[e_value.CAM_DOF_DEPTH] - tl.value[e_value.CAM_DOF_RANGE]))
	doffar = min(cam_far, max(cam_near, tl.value[e_value.CAM_DOF_DEPTH] + tl.value[e_value.CAM_DOF_RANGE]))
	dofblurnear = min(cam_far, max(cam_near, (tl.value[e_value.CAM_DOF_DEPTH] - tl.value[e_value.CAM_DOF_RANGE]) - tl.value[e_value.CAM_DOF_FADE_SIZE]))
	dofblurfar = min(cam_far, max(cam_near, (tl.value[e_value.CAM_DOF_DEPTH] + tl.value[e_value.CAM_DOF_RANGE]) + tl.value[e_value.CAM_DOF_FADE_SIZE]))
		
	var viewfrustumdofpoints = array(
		point3D(-((sizemath * dofnear) * ratio), dofnear, -sizemath * dofnear), //nbr
		point3D(-((sizemath * dofnear) * ratio), dofnear, sizemath * dofnear), //ntr
		point3D(((sizemath * dofnear) * ratio), dofnear, -sizemath * dofnear), //nbl
		point3D(((sizemath * dofnear) * ratio), dofnear, sizemath * dofnear), //ntl
		point3D(-((sizemath * doffar) * ratio), doffar, -sizemath * doffar), //fbr
		point3D(-((sizemath * doffar) * ratio), doffar, sizemath * doffar), //ftr
		point3D(((sizemath * doffar) * ratio), doffar, -sizemath * doffar), //fbl
		point3D(((sizemath * doffar) * ratio), doffar, sizemath * doffar) //ftl
	)
	var viewfrustumdofblurpoints = array(
		point3D(-((sizemath * dofblurnear) * ratio), dofblurnear, -sizemath * dofblurnear), //nbr
		point3D(-((sizemath * dofblurnear) * ratio), dofblurnear, sizemath * dofblurnear), //ntr
		point3D(((sizemath * dofblurnear) * ratio), dofblurnear, -sizemath * dofblurnear), //nbl
		point3D(((sizemath * dofblurnear) * ratio), dofblurnear, sizemath * dofblurnear), //ntl
		point3D(-((sizemath * dofblurfar) * ratio), dofblurfar, -sizemath * dofblurfar), //fbr
		point3D(-((sizemath * dofblurfar) * ratio), dofblurfar, sizemath * dofblurfar), //ftr
		point3D(((sizemath * dofblurfar) * ratio), dofblurfar, -sizemath * dofblurfar), //fbl
		point3D(((sizemath * dofblurfar) * ratio), dofblurfar, sizemath * dofblurfar) //ftl
	)
	
	// DOF outlines
	//draw_set_alpha(.5)
	
	draw_set_color(c_control_blue)
	view_shape_draw(viewfrustumdofblurpoints, mat)
	
	draw_set_color(c_control_cyan)
	view_shape_draw(viewfrustumdofpoints, mat)
	
	draw_set_color(c_white)
	//draw_set_alpha(1)
}