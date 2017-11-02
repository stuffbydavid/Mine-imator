/// action_lib_model_tex(resource)
/// @arg resource
/// @desc Sets the model texture of the given library item.

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
			if (temp_edit.model_file != null)
				res.player_skin = temp_edit.model_file.player_skin
			
			with (res)
				res_load()
				
			break
		}
		
		case e_option.DOWNLOAD_SKIN: // Download, start
		{
			popup_downloadskin_show(action_lib_model_tex)
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
	history_set_res(action_lib_model_tex, fn, temp_edit.model_tex, res)
}

with (temp_edit)
{
	if (model_tex != null)
		model_tex.count--
	model_tex = res
	if (model_tex != null)
		model_tex.count++
}

lib_preview.update = true
