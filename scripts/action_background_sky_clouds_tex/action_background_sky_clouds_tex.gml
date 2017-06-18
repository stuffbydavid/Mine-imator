/// action_background_sky_clouds_tex(resource)
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
        
        res = new_res("texture", fn)
        with (res)
            res_load()
    }
    history_set_res(action_background_sky_clouds_tex, fn, background_sky_clouds_tex, res)
}

background_sky_clouds_tex.count--
background_sky_clouds_tex = res
background_sky_clouds_tex.count++
background_sky_update_clouds()
