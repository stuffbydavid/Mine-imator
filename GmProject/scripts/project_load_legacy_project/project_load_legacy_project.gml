/// project_load_legacy_project()

function project_load_legacy_project()
{
	project_name = buffer_read_string_int()
	project_author = buffer_read_string_int()
	project_description = buffer_read_string_int()
	
	if (load_format < e_project.FORMAT_100_DEBUG)
		buffer_read_byte() // project_video_template
	
	project_video_width = buffer_read_int()
	project_video_height = buffer_read_int()
	project_video_template = find_videotemplate(project_video_width, project_video_height)
	project_video_keep_aspect_ratio = buffer_read_byte()
	project_tempo = buffer_read_byte()
	
	if (load_format >= e_project.FORMAT_100)
		timeline_repeat = buffer_read_byte()
	
	if (load_format >= e_project.FORMAT_105_2)
		timeline_marker = buffer_read_double()
	
	if (load_format >= e_project.FORMAT_100_DEMO_4)
	{
		if (object_index = app)
		{
			timeline.hor_scroll.value = buffer_read_double()
			timeline_zoom = buffer_read_double()
			timeline_zoom_goal = timeline_zoom
		}
		else
		{
			buffer_read_double() // timeline.hor_scroll.value
			buffer_read_double() // timeline_zoom
		}
	}
	
	if (load_format >= e_project.FORMAT_100_DEBUG)
	{
		timeline_region_start = buffer_read_int()
		timeline_region_end = buffer_read_int()
	}
}
