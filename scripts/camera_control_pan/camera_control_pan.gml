/// camera_control_pan(camera)
/// @arg camera

function camera_control_pan(cam)
{
	var mx, my, move;
	var mat, vert;
	mx = -((mouse_x - mouse_previous_x) / 8) * (.075 * (cam_work_zoom/50))
	my = ((mouse_y - mouse_previous_y) / 8) * (.075 * (cam_work_zoom/50))
	move = 4 * setting_move_speed
	
	app_mouse_wrap(content_x, content_y, content_width, content_height)
	
	if (!cam)
	{
		mat = matrix_create(vec3(0, 0, 0), vec3(cam_work_angle_look_z, 0, cam_work_angle_look_xy + 90), vec3(1))
		vert = vec3_mul_matrix(vec3(mx * move, 0, my * move), mat)
		
		cam_work_from[X] += vert[X]
		cam_work_from[Y] += vert[Y]
		cam_work_from[Z] += vert[Z]
		camera_work_set_angle()
	}
	else
	{
		mat = matrix_create(vec3(0, 0, 0), vec3(-cam.value[e_value.ROT_X], 0, cam.value[e_value.ROT_Z] + 180), vec3(1))
		vert = vec3_mul_matrix(vec3(mx * move, 0, my * move), mat)
		
		// Set
		tl_value_set_start(camera_control_pan, true)
		tl_value_set(e_value.POS_X, vert[X], true)
		tl_value_set(e_value.POS_Y, vert[Y], true)
		tl_value_set(e_value.POS_Z, vert[Z], true)
		tl_value_set_done()
	}
}
