/// action_bench_char_skin(resource)
/// @arg resource
/// @desc Sets the character skin of the workbench settings.

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
				
			res = new_res(fn, "skin")
			res.is_skin = bench_settings.char_model.player_skin
			
			with (res)
				res_load()
				
			break
		}
			
		case e_option.DOWNLOAD_SKIN: // Download, start
		{
			popup_downloadskin_show(action_bench_char_skin)
			
			return 0
		}
			
		case e_option.DOWNLOAD_SKIN_DONE: // Download, done
		{
			directory_create_lib(skins_directory)
			fn = skins_directory + popup_downloadskin.username + ".png"
			file_copy_lib(download_file, fn)
			
			res = new_res(fn, "downloadskin")
			res.is_skin = true
			
			with (res)
				res_load()
				
			break
		}
	}
	
	history_set_res(action_bench_char_skin, fn, bench_settings.char_skin, res)
}

bench_settings.char_skin = res
bench_settings.preview.update = true
