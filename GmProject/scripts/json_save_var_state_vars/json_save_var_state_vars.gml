/// json_save_var_state_vars(name, vars)
/// @arg name
/// @arg vars

function json_save_var_state_vars(name, vars)
{
	json_save_object_start(name)
	
	for (var i = 0; i < array_length(vars); i += 2)
		json_save_var(vars[@ i], vars[@ i + 1])
	
	json_save_object_done()
}
