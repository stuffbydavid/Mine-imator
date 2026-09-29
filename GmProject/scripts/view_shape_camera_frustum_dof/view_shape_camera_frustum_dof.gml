/// @arg timeline
/// @arg matrix
/// @arg ratio
/// @arg fovtan

function view_shape_camera_frustum_dof(tl, mat, ratio, fovtan)
{
	var dofnear, doffar, dofblurnear, dofblurfar;
	var viewfrustumdofpoints, viewfrustumdofblurpoints;
	
	dofnear = min(cam_far, max(cam_near, tl.value[e_value.CAM_DOF_DEPTH] - tl.value[e_value.CAM_DOF_RANGE]))
	doffar = min(cam_far, max(cam_near, tl.value[e_value.CAM_DOF_DEPTH] + tl.value[e_value.CAM_DOF_RANGE]))
	dofblurnear = min(cam_far, max(cam_near, (tl.value[e_value.CAM_DOF_DEPTH] - tl.value[e_value.CAM_DOF_RANGE]) - tl.value[e_value.CAM_DOF_FADE_SIZE]))
	dofblurfar = min(cam_far, max(cam_near, (tl.value[e_value.CAM_DOF_DEPTH] + tl.value[e_value.CAM_DOF_RANGE]) + tl.value[e_value.CAM_DOF_FADE_SIZE]))
		
	viewfrustumdofpoints = array(
		point3D(-((fovtan * dofnear) * ratio), dofnear, -fovtan * dofnear), // nbr
		point3D(-((fovtan * dofnear) * ratio), dofnear, fovtan * dofnear), // ntr
		point3D(((fovtan * dofnear) * ratio), dofnear, -fovtan * dofnear), // nbl
		point3D(((fovtan * dofnear) * ratio), dofnear, fovtan * dofnear), // ntl
		point3D(-((fovtan * doffar) * ratio), doffar, -fovtan * doffar), // fbr
		point3D(-((fovtan * doffar) * ratio), doffar, fovtan * doffar), // ftr
		point3D(((fovtan * doffar) * ratio), doffar, -fovtan * doffar), // fbl
		point3D(((fovtan * doffar) * ratio), doffar, fovtan * doffar) // ftl
	)
	viewfrustumdofblurpoints = array(
		point3D(-((fovtan * dofblurnear) * ratio), dofblurnear, -fovtan * dofblurnear), // nbr
		point3D(-((fovtan * dofblurnear) * ratio), dofblurnear, fovtan * dofblurnear), // ntr
		point3D(((fovtan * dofblurnear) * ratio), dofblurnear, -fovtan * dofblurnear), // nbl
		point3D(((fovtan * dofblurnear) * ratio), dofblurnear, fovtan * dofblurnear), // ntl
		point3D(-((fovtan * dofblurfar) * ratio), dofblurfar, -fovtan * dofblurfar), // fbr
		point3D(-((fovtan * dofblurfar) * ratio), dofblurfar, fovtan * dofblurfar), // ftr
		point3D(((fovtan * dofblurfar) * ratio), dofblurfar, -fovtan * dofblurfar), // fbl
		point3D(((fovtan * dofblurfar) * ratio), dofblurfar, fovtan * dofblurfar) // ftl
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
