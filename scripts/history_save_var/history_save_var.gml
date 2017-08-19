/// history_save_var(object, oldvalue, newvalue)
/// @arg object
/// @arg oldvalue
/// @arg newvalue
/// @desc Save variable of a specific object

save_var_save_id[save_var_amount] = save_id_get(argument0)
if (first)
	save_var_old_value[save_var_amount] = argument1
save_var_new_value[save_var_amount] = argument2
save_var_amount++
