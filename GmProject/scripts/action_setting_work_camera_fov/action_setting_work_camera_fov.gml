function action_setting_work_camera_fov(value, add)
{
	setting_work_camera_fov = setting_work_camera_fov * add + value
	
	view_changed()
}
