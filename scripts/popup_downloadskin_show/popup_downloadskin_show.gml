/// popup_downloadskin_show(script)
/// @arg script

with (popup_downloadskin)
{
	if (texture != null) // Free old texture
		texture_free(texture)
	
	value_script = argument0
	texture = null
	http = null
	username = ""
	fail_message = ""
	tbx_username.text = ""
}

file_delete_lib(download_image_file)
window_focus = string(popup_downloadskin.tbx_username)

popup_show(popup_downloadskin)
