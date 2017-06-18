/// history_save_var(object, oldvalue, newvalue)
/// @arg object
/// @arg oldvalue
/// @arg newvalue
/// @desc Save variable of a specific object

save_var_obj[save_var_amount] = iid_get(argument0)
if (first)
	save_var_oldval[save_var_amount] = argument1
save_var_newval[save_var_amount] = argument2
save_var_amount++
