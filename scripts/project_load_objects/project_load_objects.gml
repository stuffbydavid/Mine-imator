/// project_load_objects(map)
/// @arg map

var map = argument0;

// Templates
var templist = map[?"templates"];
if (ds_exists(templist, ds_type_list))
	for (var i = 0; i < ds_list_size(templist); i++)
		project_load_template(templist[|i])

// Timelines
var tllist = map[?"timelines"];
if (ds_exists(tllist, ds_type_list))
	for (var i = 0; i < ds_list_size(tllist); i++)
		project_load_timeline(tllist[|i])

// Resources
var reslist = map[?"resources"];
if (ds_exists(reslist, ds_type_list))
	for (var i = 0; i < ds_list_size(reslist); i++)
		project_load_resource(reslist[|i])