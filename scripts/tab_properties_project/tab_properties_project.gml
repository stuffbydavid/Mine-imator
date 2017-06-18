/// tab_properties_project()

var capwid, text, wid;

capwid = text_caption_width("projectname", 
							"projectauthor", 
							"projectdescription", 
							"projectfolderopen", 
							"projectvideosize", 
							"projectvideosizecustomwidth", 
							"projecttempo")

// Project name
tab.project.tbx_name.text = project_name
tab_control_inputbox()
if (draw_inputbox("projectname", dx, dy, dw, "", tab.project.tbx_name, null, capwid))
{
	project_changed = true
	project_name = tab.project.tbx_name.text
}
tab_next()

// Project author
tab.project.tbx_author.text = project_author
tab_control_inputbox()
if (draw_inputbox("projectauthor", dx, dy, dw, "", tab.project.tbx_author, null, capwid))
{
	project_changed = true
	project_author = tab.project.tbx_author.text
}
tab_next()

// Project description
tab.project.tbx_description.text = project_description
tab_control(100)
if (draw_inputbox("projectdescription", dx, dy, dw, "", tab.project.tbx_description, null, capwid, 100))
{
	project_changed = true
	project_description = tab.project.tbx_description.text
}
tab_next()

// Project folder
wid = text_max_width("projectfolderopen") + 20
tab_control(24)
tip_wrap = false
tip_set(string_remove_newline(project_folder), dx, dy, dw - wid, 24)
draw_label(text_get("projectfolder") + ":", dx, dy + 12, fa_left, fa_middle)
draw_label(string_limit(string_remove_newline(project_folder), dw - capwid - wid - 8), dx + capwid, dy + 12, fa_left, fa_middle)
if (draw_button_normal("projectfolderopen", dx + dw - wid, dy, wid, 24))
	action_toolbar_open_folder()
tab_next()

// Video size
if (project_video_template = 0)
	text = text_get("projectvideosizecustom")
else
	text = project_video_template.name + " (" + string(project_video_template.width) + "x" + string(project_video_template.height) + ")"
tab_control(24)
draw_button_menu("projectvideosize", e_menu.LIST, dx, dy, dw, 24, project_video_template, text, action_project_video_template, null, 0, capwid)
tab_next()

// Custom
if (project_video_template = 0)
{
	tab_control_dragger()
	draw_dragger("projectvideosizecustomwidth", dx, dy, 140, project_video_width, 1, 1, no_limit, 1280, 1, tab.project.tbx_video_size_custom_width, action_project_video_width, capwid)
	draw_dragger("projectvideosizecustomheight", dx + 140, dy, dw - 140, project_video_height, 1, 1, no_limit, 720, 1, tab.project.tbx_video_size_custom_height, action_project_video_height)
	tab_next()
	
	tab_control_checkbox()
	draw_checkbox("projectvideosizecustomkeepaspectratio", dx, dy, project_video_keep_aspect_ratio, action_project_video_keep_aspect_ratio)
	tab_next()
}

// Tempo
tab_control_meter()
draw_meter("projecttempo", dx, dy, dw, project_tempo, 50, 1, 100, 24, 1, tab.project.tbx_tempo, action_project_tempo, capwid)
tab_next()
