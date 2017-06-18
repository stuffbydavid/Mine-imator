/// action_lib_char_bodypart(part)
/// @arg part
/// @desc Changes the character body part.

var part;

if (history_undo)
    part = history_data.oldval
else if (history_redo)
    part = history_data.newval
else
{
    part = argument0
    history_set_var(action_lib_char_bodypart, temp_edit.char_bodypart, part, false)
}
    
with (temp_edit)
{
    char_bodypart = part
    temp_update_bodypart()
    temp_update_display_name()
}

tl_update_matrix()

lib_preview.update = true
