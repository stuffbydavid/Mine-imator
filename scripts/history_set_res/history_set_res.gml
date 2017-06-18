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
hobj.fn = fn
hobj.fnout = ""
hobj.type = ""
hobj.oldres = iid_get(oldres)
hobj.newres = iid_get(newres)
hobj.replaced = false

if (newres && newres.object_index = obj_resource) // Not camera
{
	hobj.type = newres.type
	hobj.fnout = newres.filename_out
	hobj.replaced = newres.replaced
}
	
history[0] = hobj

return hobj
