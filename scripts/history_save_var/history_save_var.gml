/// history_save_var(object, oldvalue, newvalue)
/// @arg object
/// @arg oldvalue
/// @arg newvalue
/// @desc Save variable of a specific object

function history_save_var(object, oldvalue, newvalue)
{
	save_var_save_id[save_var_amount] = save_id_get(object)
	if (first)
		save_var_old_value[save_var_amount] = oldvalue
	save_var_new_value[save_var_amount] = newvalue
	save_var_amount++
}
