/// action_lib_pc_type_sprite_angle_add(value, add)
/// @arg value
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
	history_set_var(action_lib_pc_type_scale_add, ptype_edit.sprite_angle_add, ptype_edit.sprite_angle_add * add + val, true)
}

ptype_edit.sprite_angle_add = ptype_edit.sprite_angle_add * add + val
