/// @arg camera

function camera_control_zoom(cam)
{
	var my = ((mouse_y - mouse_previous_y) / 8) * (.25 * (cam_work_zoom/50));
	//var my = ((display_mouse_get_y()) / 4);
	app_mouse_wrap(content_x, content_y, content_width, content_height)
	
	if (!cam)
	{
		cam_work_zoom += my
		cam_work_zoom = clamp(cam_work_zoom, cam_near, cam_far)
		cam_work_zoom_goal = cam_work_zoom
		camera_work_set_from()
	}
}
