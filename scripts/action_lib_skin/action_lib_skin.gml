/// action_lib_skin(resource)
/// @arg resource
/// @desc Sets the character skin of the given library item.

var res, fn;
fn = ""

if (history_undo)
	res = history_undo_res()
else if (history_redo)
	res = history_redo_res()
else
{
	res = argument0
	switch (res)
	{
		case e_option.BROWSE: // Load new
		{
			fn = file_dialog_open_image_pack()
			if (!file_exists_lib(fn))
				return 0
			
			res = new_res(fn, e_res_type.SKIN)
			res.player_skin = temp_edit.model_file.player_skin
			
			with (res)
				res_load()
				
			break
		}
		case e_option.DOWNLOAD_SKIN: // Download, start
		{
			popup_downloadskin_show(action_lib_skin)
			
			return 0
		}
		
		case e_option.DOWNLOAD_SKIN_DONE: // Download, done
		{
			directory_create_lib(skins_directory)
			fn = skins_directory + popup_downloadskin.username + ".png"
			file_copy_lib(download_image_file, fn)
			
			res = new_res(fn, e_res_type.DOWNLOADED_SKIN)
			res.player_skin = true
			
			with (res)
				res_load()
				
			break
		}
	}
	history_set_res(action_lib_skin, fn, temp_edit.skin, res)
}

with (temp_edit)
{
	skin.count--
	skin = res
	skin.count++
}

lib_preview.update = true
