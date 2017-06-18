/// action_lib_pc_type_alpha_add_random_min(value, add)
/// @arg value
/// @arg add

var val, add;
add = false

if (history_undo)
    val = history_data.oldval
else if (history_redo)
    val = history_data.newval
else
{
    val = argument0
    add = argument1
    history_set_var(action_lib_pc_type_alpha_add_random_min, ptype_edit.alpha_add_random_min * 100, ptype_edit.alpha_add_random_min * add * 100 + val, true)
}

ptype_edit.alpha_add_random_min = ptype_edit.alpha_add_random_min * add + val / 100
