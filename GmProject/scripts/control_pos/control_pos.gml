function control_pos(s, e, axis, mat, retstart)
{
	var startpos = vec3(0); startpos[axis] = s;
	var endpos = vec3(0); endpos[axis] = e;
	
	if (view_control_edit = null)
	{
		var endpos3d = vec3(0);
		endpos3d[axis] = point3D_distance(cam_from, tl_edit.world_pos) * view_3d_control_size * view_control_ratio
		endpos3d = point3D_mul_matrix(endpos3d, mat)
		
		if (control_test_point(endpos3d, tl_edit.world_pos, 0) && setting_gizmos_face_camera)
		{
			startpos = vec3_mul(startpos, -1)
			endpos = vec3_mul(endpos, -1)
		
			view_control_move_flip_axis[axis] = true
		}
		else
			view_control_move_flip_axis[axis] = false
	}
	else
	{
		if (view_control_move_flip_axis[axis])
		{
			startpos = vec3_mul(startpos, -1)
			endpos = vec3_mul(endpos, -1)
		}
	}
	
	if (retstart)
		return point3D_mul_matrix(startpos, mat)
	else
		return point3D_mul_matrix(endpos, mat)
}
