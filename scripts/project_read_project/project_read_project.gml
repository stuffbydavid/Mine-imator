/// project_read_project()
/*
project_name = buffer_read_string_int()						debug("project_name", project_name)
project_author = buffer_read_string_int()					debug("project_author", project_author)
project_description = buffer_read_string_int()				debug("project_description", project_description)

if (load_format < project_100debug)
	buffer_read_byte() // project_video_template
	
project_video_width = buffer_read_int()						debug("project_video_width", project_video_width)
project_video_height = buffer_read_int()					debug("project_video_height", project_video_height)
project_video_template = find_videotemplate(project_video_width, project_video_height)

project_video_keep_aspect_ratio = buffer_read_byte()		debug("project_video_keep_aspect_ratio", project_video_keep_aspect_ratio)
project_tempo = buffer_read_byte()							debug("project_tempo", project_tempo)

if (load_format >= project_100)
{
	timeline_repeat = buffer_read_byte()					debug("timeline_repeat", timeline_repeat)
}

if (load_format >= project_105_2)
{
	timeline_marker = buffer_read_double()					debug("timeline_marker", timeline_marker)
}

if (load_format >= project_100demo4)
{
	if (object_index = app)
	{
		timeline.hor_scroll.value = buffer_read_double()	debug("timeline.hscroll.val", app.timeline.hor_scroll.value)
		timeline_zoom = buffer_read_double()				debug("timeline_zoom", timeline_zoom)
		timeline_zoom_goal = timeline_zoom
	}
	else
	{
		buffer_read_double()
		buffer_read_double()
	}
}

if (load_format >= project_100debug)
{
	timeline_region_start = buffer_read_int()				debug("timeline_region_start", timeline_region_start)
	timeline_region_end = buffer_read_int()					debug("timeline_region_end", timeline_region_end)
}
*/