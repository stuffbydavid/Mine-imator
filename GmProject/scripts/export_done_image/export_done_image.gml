/// export_done_image()

function export_done_image()
{
	render_free()
	
	surface_free(export_surface)
	export_surface = null
	window_state = ""
	
	render_watermark = false
	render_background = true
	render_hidden = false
	
	toast_new(e_toast.POSITIVE, text_get("alertexportimage"))
	toast_add_action("alertexportimageview", popup_open_url, export_filename)
}
