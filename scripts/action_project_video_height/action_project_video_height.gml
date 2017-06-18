/// action_project_video_height(value, add)
/// @arg value
/// @arg add

var val, add, ratio, 
add = false

if (history_undo)
{
	project_video_width = history_data.oldwidth
	project_video_height = history_data.oldheight
	return 0
}
else if (history_redo)
	val = history_data.newheight
else
{
	var hobj;
	val = argument0
	add = argument1
	history_pop()
	
	if (history_amount > 0 && history[0].script = action_project_video_height)
		hobj = history[0]
	else
	{
		history_push()
		hobj = new_history(action_project_video_height)
		hobj.oldwidth = project_video_width
		hobj.oldheight = project_video_height
	}
	hobj.newheight = project_video_height * add + val
	history[0] = hobj
}

ratio = project_video_width / project_video_height
project_video_height = project_video_height * add + val

if (project_video_keep_aspect_ratio)
	project_video_width = max(1, round(project_video_height * ratio))
