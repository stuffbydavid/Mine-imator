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
