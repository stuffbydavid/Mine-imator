function action_project_video_height(value, add)
{
	if (history_undo)
	{
		project_video_width = history_data.old_width
		project_video_height = history_data.old_height
		return 0
	}
	else if (history_redo)
		value = history_data.new_height
	else
	{
		history_pop()

		var hobj;
		if (history_amount > 0 && history[0].script = action_project_video_height)
			hobj = history[0]
		else
		{
			history_push()
			
			hobj = new_history(action_project_video_height)
			hobj.old_width = project_video_width
			hobj.old_height = project_video_height
		}
		
		hobj.new_height = project_video_height * add + value
		history[0] = hobj
	}
	
	var ratio = project_video_width / project_video_height;
	project_video_height = project_video_height * add + value
	
	if (project_video_keep_aspect_ratio)
		project_video_width = max(1, round(project_video_height * ratio))
}
