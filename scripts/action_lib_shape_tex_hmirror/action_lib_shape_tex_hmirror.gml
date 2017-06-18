/// action_lib_shape_tex_hmirror(hmirror)
/// @arg hmirror

var hmirror;

if (history_undo)
    hmirror = history_data.oldval
else if (history_redo)
    hmirror = history_data.newval
else
{
    hmirror = argument0
    history_set_var(action_lib_shape_tex_hmirror, temp_edit.shape_tex_hmirror, hmirror, false)
}

with (temp_edit)
{
    shape_tex_hmirror = hmirror
    temp_update_shape()
}
lib_preview.update = true
