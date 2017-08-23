/// action_lib_item_bounce(bounce)
/// @arg bounce

var bounche;

if (history_undo)
	bounche = history_data.old_value
else if (history_redo)
	bounche = history_data.new_value
else
{
	bounche = argument0
	history_set_var(action_lib_item_bounce, temp_edit.item_bounce, bounche, false)
}

temp_edit.item_bounce = bounche
