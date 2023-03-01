/// popup_downloadskin_show(script)
/// @arg script

function popup_downloadskin_show(script)
{
	with (popup_downloadskin)
	{
		if (texture != null) // Free old texture
			texture_free(texture)
		
		value_script = script
		texture = null
		username = ""
		fail_message = ""
		tbx_username.text = ""
	}
	
	file_delete_lib(download_image_file)
	window_focus = string(popup_downloadskin.tbx_username)
	
	popup_show(popup_downloadskin)
}
