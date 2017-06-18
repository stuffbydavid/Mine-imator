/// action_res_remove()

if (history_undo)
    with (history_data)
        res_edit = history_restore_res(save_res)
else
{
    var index;
    
    if (!history_redo)
        with (history_set(action_res_remove))
            save_res = history_save_res(res_edit)
    
    with (res_edit)
        instance_destroy()
}

tl_update_matrix()

lib_preview.update = true
res_preview.update = true
