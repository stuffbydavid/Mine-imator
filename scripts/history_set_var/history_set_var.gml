/// history_set_var(script, oldvalue, newvalue, combine)
/// @arg script
/// @arg oldvalue
/// @arg newvalue
/// @arg combine
/// @desc Registering history for changing a single variable.

var script, oldval, newval, combine, hobj;
script = argument0
oldval = argument1
newval = argument2
combine = argument3
    
history_pop()

if (combine && history_amount > 0 &&
	history[0].script = script &&
	history[0].save_temp_edit = iid_get(temp_edit) &&
	history[0].save_axis_edit = axis_edit) // Add to existing
    hobj = history[0]
else
{
    history_push()
    
    log("Action Set variable", script_get_name(script), oldval, newval, combine)
    
    hobj = new_history(script)
    hobj.oldval = oldval
    
    history[0] = hobj
}

hobj.newval = newval

return hobj
