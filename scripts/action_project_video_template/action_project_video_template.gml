/// action_project_video_template(videotemplate)
/// @arg videotemplate

function action_project_video_template(argument0)
{
	if (history_undo)
	{
		project_video_template = history_data.oldtemplate
		project_video_width = history_data.oldwidth
		project_video_height = history_data.oldheight
		return 0
	}
	else if (history_redo)
		argument0 = history_data.newtemplate
	else
	{
		var hobj = history_set(action_project_video_template);
		hobj.oldtemplate = project_video_template
		hobj.newtemplate = argument0
		hobj.oldwidth = project_video_width
		hobj.oldheight = project_video_height
	}
	
	project_video_template = argument0
	if (project_video_template > 0)
	{
		project_video_width = project_video_template.width
		project_video_height = project_video_template.height
	}
}
