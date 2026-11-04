function action_tl_frame_cam_video_template(videotemplate)
{
	tl_value_set_start(action_tl_frame_cam_video_template, false)
	
	app.frame_editor.camera.video_template = videotemplate
	if (videotemplate > 0)
	{
		tl_value_set(e_value.CAM_SIZE_USE_PROJECT, false, false)
		tl_value_set(e_value.CAM_WIDTH, videotemplate.width, false)
		tl_value_set(e_value.CAM_HEIGHT, videotemplate.height, false)
	}
	else if (videotemplate = 0) // Custom
		tl_value_set(e_value.CAM_SIZE_USE_PROJECT, false, false)
	else // Inherit project size
		tl_value_set(e_value.CAM_SIZE_USE_PROJECT, true, false)
	
	tl_value_set_done()
}
