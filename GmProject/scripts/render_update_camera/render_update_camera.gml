function render_update_camera()
{
	var shake = null;
	if (render_camera_effects != null && render_camera_effect_enabled[e_cam_fx.SHAKE] &&
		(render_camera != null || (render_view_current = view_second && render_effects)))
	{
		var shaketime = app.timeline_marker / app.project_tempo;
		for (var axis = 0; axis < 3; axis++)
		{
			var strength = render_camera_effects[e_value.CAM_FX_SHAKE_STRENGTH_X + axis];
			if (strength = 0)
				continue

			if (shake = null)
				shake = vec3(0)

			var noisetime = shaketime * render_camera_effects[e_value.CAM_FX_SHAKE_SPEED_X + axis];
			// Cache noise inputs, not strength or camera identity, so live edits remain immediate
			if (!render_shake_cached[axis] || render_shake_time[axis] != noisetime)
			{
				render_shake_noise[axis] = (axis = 0) ? simplex1d_lib(noisetime) : simplex2d_lib(noisetime, axis * 1000)
				render_shake_time[axis] = noisetime
				render_shake_cached[axis] = true
			}

			shake[axis] = render_shake_noise[axis] * strength
		}
	}

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

		if (shake != null)
		{
			var forward, right, up, workmat, workshake;
			forward = vec3_normalize(point3D_sub(cam_to, cam_from))
			right = vec3_normalize(vec3_cross(forward, cam_up))
			up = vec3_normalize(vec3_cross(right, forward))

			workmat = [ right[X], right[Y], right[Z], 0,
						forward[X], forward[Y], forward[Z], 0,
						up[X], up[Y], up[Z], 0,
						cam_from[X], cam_from[Y], cam_from[Z], 1 ]
			workshake = render_camera_effects[e_value.CAM_FX_SHAKE_MODE] ? matrix_create(shake, vec3(0), vec3(1)) : matrix_create(vec3(0), shake, vec3(1))
			workmat = matrix_multiply(workshake, workmat)

			cam_from = point3D(workmat[MAT_X], workmat[MAT_Y], workmat[MAT_Z])
			cam_to = point3D_mul_matrix(point3D(0, 1, 0), workmat)
			cam_up = vec3(workmat[8], workmat[9], workmat[10])
		}
	}
	else
	{
		var mat, pos;
		mat = render_camera.matrix
		pos = render_camera.world_pos
		
		// Camera shake
		if (shake != null)
		{
			// Create matrix
			var shakemat;
			if (render_camera_effects[e_value.CAM_FX_SHAKE_MODE])
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
	
	env_sky_update()
}
