/// action_lib_text_font(resource)
/// @arg resource

function action_lib_text_font(res)
{
	var fn;
	fn = ""

	if (history_undo)
		res = history_undo_res()
	else if (history_redo)
		res = history_redo_res()
	else
	{
		if (res = e_option.BROWSE)
		{
			fn = file_dialog_open_font()
			if (!file_exists_lib(fn))
				return 0
			
			res = new_res(fn, e_res_type.FONT)
			with (res)
				res_load()
		}
		
		history_set_res(action_lib_text_font, fn, temp_edit.text_font, res)
	}
	
	with (temp_edit)
	{
		if (text_font != null)
			text_font.count--
		text_font = res
		text_font.count++
	}
	
	lib_preview.update = true
}
