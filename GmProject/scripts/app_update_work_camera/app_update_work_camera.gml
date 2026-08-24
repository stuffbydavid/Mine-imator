/// app_update_work_camera()

function app_update_work_camera()
{
	if (cam_work_jump)
	{
		cam_work_jump = false
		return 0
	}
	
	if (window_busy = "")
	{
		if (tl_edit != null) 
		{
			cam_work_focus_tl = tl_edit
			
			if (cam_work_focus_tl.world_pos_2d_error)
				cam_work_focus_tl = null
			
			if (cam_work_focus_tl)
				cam_work_focus = point3D_copy(cam_work_focus_tl.world_pos)
		}
		else
			cam_work_focus_tl = null
	}
	
	cam_work_zoom += (cam_work_zoom_goal - cam_work_zoom) / max(1, 3 / delta)
	//cam_work_zoom = clamp(cam_work_zoom, 1, project_render_distance)
	
	if (cam_work_focus_last[X] != cam_work_focus[X] || 
		cam_work_focus_last[Y] != cam_work_focus[Y] || 
		cam_work_focus_last[Z] != cam_work_focus[Z])
		camera_work_set_angle()
	
	cam_work_focus_last = point3D_copy(cam_work_focus)
	camera_work_set_from()
}
