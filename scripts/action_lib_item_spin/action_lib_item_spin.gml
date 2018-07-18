/// action_lib_item_spin(spin)
/// @arg spin

var spin;

if (history_undo)
	spin = history_data.old_value
else if (history_redo)
	spin = history_data.new_value
else
{
	spin = argument0
	history_set_var(action_lib_item_spin, temp_edit.item_spin, spin, false)
}
	
temp_edit.item_spin = spin
