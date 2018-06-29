/// action_lib_item_bounce(bounce)
/// @arg bounce

var bounce;

if (history_undo)
	bounce = history_data.old_value
else if (history_redo)
	bounce = history_data.new_value
else
{
	bounce = argument0
	history_set_var(action_lib_item_bounce, temp_edit.item_bounce, bounce, false)
}

temp_edit.item_bounce = bounce
lib_preview.update = true
