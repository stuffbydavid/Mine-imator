/// history_set(script)
/// @arg script
/// @desc Registering history for a generic action.

var script, hobj;
script = argument0

history_pop()
history_push()

log("Action", script_get_name(script))

hobj = new_history(script)

history[0] = hobj

return hobj
