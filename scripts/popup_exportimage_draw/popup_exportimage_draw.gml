/// popup_exportimage_draw()

var capwid = text_caption_width("exportimageimagesize", "exportimageimagesizecustomwidth")

// Video size
if (project_video_template = 0)
    text = text_get("projectvideosizecustom")
else
    text = project_video_template.name + " (" + string(project_video_template.width) + "x" + string(project_video_template.height) + ")"

tab_control(24)
draw_button_menu("exportimageimagesize", e_menu.LIST, dx, dy, dw, 24, project_video_template, text, action_project_video_template, null, 0, capwid)
tab_next()

// Custom
if (project_video_template = 0)
{
    tab_control_dragger()
    draw_dragger("exportimageimagesizecustomwidth", dx, dy, 140, project_video_width, 1, 1, no_limit, 1280, 1, popup.tbx_video_size_custom_width, action_project_video_width, capwid)
    draw_dragger("exportimageimagesizecustomheight", dx + 140, dy, dw - 140, project_video_height, 1, 1, no_limit, 720, 1, popup.tbx_video_size_custom_height, action_project_video_height)
    tab_next()
    tab_control_checkbox()
    draw_checkbox("exportimageimagesizecustomkeepaspectratio", dx, dy, project_video_keep_aspect_ratio, action_project_video_keep_aspect_ratio)
    tab_next()
}

dy += 10

// Remove background
tab_control_checkbox()
draw_checkbox("exportimageremovebackground", dx, dy, popup.remove_background, action_toolbar_exportimage_remove_background)
tab_next()

// Include hidden
tab_control_checkbox()
draw_checkbox("exportimageincludehidden", dx, dy, popup.include_hidden, action_toolbar_exportimage_include_hidden)
tab_next()

// High quality
tab_control_checkbox()
draw_checkbox("exportimagehighquality", dx, dy, popup.high_quality, action_toolbar_exportimage_high_quality)
tab_next()

// Save
dw = 100
dh = 32
dx = content_x + content_width / 2-dw - 4
dy = content_y + content_height - 32
if (draw_button_normal("exportimagesave", dx, dy, dw, 32))
    action_toolbar_exportimage_save()

// Cancel
dx = content_x + content_width / 2+4
if (draw_button_normal("exportimagecancel", dx, dy, dw, 32))
    popup_close()
