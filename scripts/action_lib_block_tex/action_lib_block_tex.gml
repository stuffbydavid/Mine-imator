/// action_lib_block_tex(resource)
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
        
        res = new_res("blocksheet", fn)
        with (res)
            res_load()
    }
    history_set_res(action_lib_block_tex, fn, temp_edit.block_tex, res)
}

with (temp_edit)
{
    block_tex.count--
    block_tex = res
    block_tex.count++
}

lib_preview.update = true
