/// action_lib_char_bodypart_model(model)
/// @arg model
/// @desc Changes the character body part.

var model;

if (history_undo)
	model = history_data.oldval
else if (history_redo)
	model = history_data.newval
else
{
	model = argument0
	history_set_var(action_lib_char_bodypart_model, temp_edit.char_model, model, false)
}
	
with (temp_edit)
{
	char_model = model
	temp_update_bodypart()
	temp_update_display_name()
}

tl_update_matrix()

lib_preview.update = true
