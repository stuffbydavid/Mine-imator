/// render_update_camera()

function render_update_camera()
{
	if (!render_camera) // Use work camera
	{
		var xx, yy, zz, cx, cy;
		cam_from = point3D_copy(app.cam_work_from)
		cam_to[X] = cam_work_from[X] + lengthdir_x(1, cam_work_angle_look_xy + 180) * lengthdir_x(1, cam_work_angle_look_z)
		cam_to[Y] = cam_work_from[Y] + lengthdir_y(1, cam_work_angle_look_xy + 180) * lengthdir_x(1, cam_work_angle_look_z)
		cam_to[Z] = cam_work_from[Z] + lengthdir_z(1, cam_work_angle_look_z)
		
		xx = cam_to[X] - cam_from[X];
		yy = cam_to[Y] - cam_from[Y];
		zz = cam_to[Z] - cam_from[Z];
		cx = lengthdir_x(1, -cam_work_roll) / sqrt(xx * xx + yy * yy + zz * zz)
		cy = lengthdir_y(1, -cam_work_roll)
		cam_up[X] = -cx * xx * zz - cy * yy
		cam_up[Y] = cy * xx - cx * yy * zz
		cam_up[Z] = cx * (xx * xx + yy * yy)
		
		cam_fov = 45
	}
	else
	{
		var mat = render_camera.matrix;
		var pos = render_camera.world_pos;
		
		// Camera shake
		if (render_camera.value[e_value.CAM_SHAKE])
		{
			var shakerot = vec3(
				simplex_lib(((app.timeline_marker/app.project_tempo) * 10 + render_camera.value[e_value.CAM_SHAKE_HORIZONTAL_OFFSET]) * (render_camera.value[e_value.CAM_SHAKE_HORIZONTAL_SPEED] * 0.025), 3.0) * render_camera.value[e_value.CAM_SHAKE_HORIZONTAL_STRENGTH],
				0,
				simplex_lib(((app.timeline_marker/app.project_tempo) * 10 + render_camera.value[e_value.CAM_SHAKE_VERTICAL_OFFSET]) * (render_camera.value[e_value.CAM_SHAKE_VERTICAL_SPEED] * 0.025), 0.0) * render_camera.value[e_value.CAM_SHAKE_VERTICAL_STRENGTH],
			);
			
			shakerot = vec3_mul(shakerot, render_camera.value[e_value.CAM_SHAKE_STRENGTH])
			
			var shakemat = matrix_create(shakerot, vec3(0), vec3(1));
			mat = matrix_multiply(shakemat, mat)
			pos = point3D(mat[MAT_X], mat[MAT_Y], mat[MAT_Z])
		}
		
		var pos_lookat = point3D_mul_matrix(point3D(0, 1, 0), mat);
		cam_from = point3D_copy(pos)
		cam_to = point3D_copy(pos_lookat)
		cam_up[X] = mat[8]
		cam_up[Y] = mat[9]
		cam_up[Z] = mat[10]
		cam_fov = max(1, render_camera.value[e_value.CAM_FOV])
	}
	
	cam_near = clip_near
	cam_far = clip_far
	
	// Render modes can vary in zfar, keep original zfar
	cam_far_prev = cam_far
	
	background_sky_update()
}