/// iid_find(iid)
/// @arg iid
/// @desc Finds the instance with the given save ID.
/*
var i = argument0;

if (i = 0) // App
	return 0
	
with (obj_template)
	if (iid = i)
		return id

with (obj_timeline)
	if (iid = i)
		return id

with (obj_resource)
	if (iid = i)
		return id

with (obj_particle_type)
	if (iid != null && iid = i)
		return id

return null
*/