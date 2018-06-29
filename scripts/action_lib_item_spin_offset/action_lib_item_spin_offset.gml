/// action_lib_item_spin_offset(offset, add)
/// @arg offset
/// @arg add

var val, add;
add = false

if (history_undo)
	val = history_data.old_value
else if (history_redo)
	val = history_data.new_value
else
{
	val = argument0
	add = argument1
	history_set_var(action_lib_item_spin_offset, temp_edit.item_spin_offset, temp_edit.item_spin_offset * add + val, true)
}
	
temp_edit.item_spin_offset = temp_edit.item_spin_offset * add + val
