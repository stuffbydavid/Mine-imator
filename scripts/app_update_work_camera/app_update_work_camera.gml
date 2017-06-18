/// app_update_work_camera()

if (window_busy = "")
{
    if (tl_edit) 
	{
        cam_work_focus_tl = tl_edit
        
        if (cam_work_focus_tl.pos_2d_error)
            cam_work_focus_tl = null
            
        if (cam_work_focus_tl)
            cam_work_focus = point3D_copy(cam_work_focus_tl.pos)
    }
	else
        cam_work_focus_tl = null
}

cam_work_zoom += (cam_work_zoom_goal - cam_work_zoom) / max(1, 4 / delta)

if (cam_work_focus_last[X] != cam_work_focus[X] || 
	cam_work_focus_last[Y] != cam_work_focus[Y] || 
	cam_work_focus_last[Z] != cam_work_focus[Z])
    cam_work_set_angle()

cam_work_focus_last = point3D_copy(cam_work_focus)
cam_work_set_from()
