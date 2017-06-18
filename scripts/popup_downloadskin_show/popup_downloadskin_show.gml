/// popup_downloadskin_show(script)
/// @arg script

if (popup_downloadskin.texture) // Clear old
	texture_free(popup_downloadskin.texture)

file_delete_lib(download_file)

popup_downloadskin.value_script = argument0
popup_downloadskin.texture = null
popup_downloadskin.http = null
popup_downloadskin.username = ""
popup_downloadskin.fail_message = ""
popup_downloadskin.tbx_username.text = ""

window_focus = string(popup_downloadskin.tbx_username)

popup_show(popup_downloadskin)
