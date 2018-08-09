/// action_toolbar_exportimage_save()

var fn, surf;
fn = file_dialog_save_image(project_name)

if (fn = "")
	return 0
	
log("Export image", fn)

// Render and save
render_hidden = popup_exportimage.include_hidden
render_background = !popup_exportimage.remove_background
render_watermark = setting_render_watermark

log("Hidden", yesno(render_hidden))
log("Render background", yesno(render_background))
log("Watermark", yesno(render_watermark))
log("High Quality", yesno(popup_exportimage.high_quality))
log("Size", project_video_width, project_video_height)

app_update_cameras(popup_exportimage.high_quality)
render_start(null, timeline_camera)
if (popup_exportimage.high_quality)
	render_high()
else
	render_low()
surf = render_done()
surface_save_lib(surf, fn)

render_watermark = false
render_background = true
render_hidden = false

// Clean up
render_free()
surface_free(surf)

// Return to program
alert_show(text_get("alertexportimagetitle"), "", icons.SAVE_SMALL, "alertexportimagebutton", fn, 5000)
popup_close()
