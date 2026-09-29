function render_update_camera()
{
	if (!render_camera) // Use work camera
	{
		var xx, yy, zz, cx, cy;
		cam_from = point3D_copy(app.cam_work_from)
		cam_to = point3D(
			cam_work_from[X] + lengthdir_x(1, cam_work_angle_look_xy + 180) * lengthdir_x(1, cam_work_angle_look_z),
			cam_work_from[Y] + lengthdir_y(1, cam_work_angle_look_xy + 180) * lengthdir_x(1, cam_work_angle_look_z),
			cam_work_from[Z] + lengthdir_z(1, cam_work_angle_look_z)
		)
		
		xx = cam_to[X] - cam_from[X]
		yy = cam_to[Y] - cam_from[Y]
		zz = cam_to[Z] - cam_from[Z]
		cx = lengthdir_x(1, -cam_work_roll) / sqrt(xx * xx + yy * yy + zz * zz)
		cy = lengthdir_y(1, -cam_work_roll)
		
		cam_up = point3D(
			-cx * xx * zz - cy * yy,
			cy * xx - cx * yy * zz,
			cx * (xx * xx + yy * yy)
		)
		cam_fov = 45
	}
	else
	{
		var mat, pos;
		mat = render_camera.matrix
		pos = render_camera.world_pos
		
		// Camera shake
		if (render_camera.value[e_value.CAM_SHAKE])
		{			
			var shake = vec3(
				simplex1d_lib((app.timeline_marker/app.project_tempo) * render_camera.value[e_value.CAM_SHAKE_SPEED_X]) * render_camera.value[e_value.CAM_SHAKE_STRENGTH_X],
				simplex2d_lib((app.timeline_marker/app.project_tempo) * render_camera.value[e_value.CAM_SHAKE_SPEED_Y], 1000) * render_camera.value[e_value.CAM_SHAKE_STRENGTH_Y],
				simplex2d_lib((app.timeline_marker/app.project_tempo) * render_camera.value[e_value.CAM_SHAKE_SPEED_Z], 2000) * render_camera.value[e_value.CAM_SHAKE_STRENGTH_Z]
			);
			
			// Create matrix
			var shakemat;
			
			if (render_camera.value[e_value.CAM_SHAKE_MODE])
				shakemat = matrix_create(shake, vec3(0), vec3(1))
			else
				shakemat = matrix_create(vec3(0), shake, vec3(1))
			
			mat = matrix_multiply(shakemat, mat)
			pos = point3D(mat[MAT_X], mat[MAT_Y], mat[MAT_Z])
		}
		
		var poslookat = point3D_mul_matrix(point3D(0, 1, 0), mat);
		cam_from = point3D_copy(pos)
		cam_to = point3D_copy(poslookat)
		cam_up = vec3(mat[8], mat[9], mat[10])
		cam_fov = max(1, render_camera.value[e_value.CAM_FOV])
	}
	
	cam_near = clip_near
	cam_far = app.project_render_distance
	
	// Render modes can vary in zfar, keep original zfar
	cam_far_prev = cam_far
	
	background_sky_update()
}
