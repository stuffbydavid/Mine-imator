/// action_background_image(resource)
/// @arg resource
/// @desc Sets background image.

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
		fn = file_dialog_open_image()
		if (!file_exists_lib(fn))
			return 0
		
		res = new_res("texture", fn)
		with (res)
			res_load()
	}
	history_set_res(action_background_image, fn, background_image, res)
}

if (background_image)
	background_image.count--

background_image = res

if (background_image) 
	background_image.count++
