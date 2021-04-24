/// action_tl_frame_cam_video_template(videotemplate)
/// @arg videotemplate

function action_tl_frame_cam_video_template(videotemplate)
{
	var tid;
	tl_value_set_start(action_tl_frame_cam_video_template, false)
	
	tid = videotemplate
	app.frame_editor.camera.video_template = tid
	if (tid > 0)
	{
		tl_value_set(e_value.CAM_SIZE_USE_PROJECT, false, false)
		tl_value_set(e_value.CAM_WIDTH, tid.width, false)
		tl_value_set(e_value.CAM_HEIGHT, tid.height, false)
	}
	else if (tid = 0) // Custom
		tl_value_set(e_value.CAM_SIZE_USE_PROJECT, false, false)
	else // Inherit project size
		tl_value_set(e_value.CAM_SIZE_USE_PROJECT, true, false)
	
	tl_value_set_done()
}
