/// action_lib_item_spin(spin)
/// @arg spin

function action_lib_item_spin(spin)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_item_spin, temp_edit.item_spin, spin, false)
	
	temp_edit.item_spin = spin
}
