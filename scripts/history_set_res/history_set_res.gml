/// history_set_res(script, filename, oldresource, newresource)
/// @arg script
/// @arg filename
/// @arg oldresource
/// @arg newresource
/// @desc Registering history for selecting/loading a new resource.

var script, fn, oldres, newres, hobj;
script = argument0
fn = argument1
oldres = argument2
newres = argument3

history_pop()
history_push()

log("Action Load resource", script_get_name(script), fn)

hobj = new_history(script)
hobj.filename = fn
hobj.type = ""
hobj.old_res_save_id = save_id_get(oldres)
hobj.new_res_save_id = save_id_get(newres)
hobj.replaced = false

if (newres && newres.object_index = obj_resource) // Not camera
{
	hobj.type = newres.type
	hobj.replaced = newres.replaced
}
	
history[0] = hobj

return hobj
