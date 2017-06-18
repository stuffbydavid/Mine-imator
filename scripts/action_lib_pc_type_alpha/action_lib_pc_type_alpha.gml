/// action_lib_pc_type_alpha(value, add)
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
    history_set_var(action_lib_pc_type_alpha, ptype_edit.alpha * 100, ptype_edit.alpha * add * 100 + val, true)
}

ptype_edit.alpha = ptype_edit.alpha * add + val / 100
