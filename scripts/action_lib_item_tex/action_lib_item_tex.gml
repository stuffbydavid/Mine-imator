/// action_lib_item_tex(resource)
/// @arg resource

var res, fn;
fn = ""

if (history_undo)
	res = history_undo_res()
else if (history_redo)
	res = history_redo_res()
else
{
	res = argument0
	if (res = e_option.BROWSE)
	{
		fn = file_dialog_open_image_pack()
		if (!file_exists_lib(fn))
			return 0
		
		res = new_res(fn, "itemsheet")
		with (res)
			res_load()
	}
	history_set_res(action_lib_item_tex, fn, temp_edit.item_tex, res)
}

with (temp_edit)
{
	item_tex.count--
	item_tex = res
	item_tex.count++
	temp_update_item()
}

lib_preview.update = true
