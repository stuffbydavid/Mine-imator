/// project_load_legacy_objects()

function project_load_legacy_objects()
{
	// Templates
	var am = buffer_read_int();
	debug("templates", am)
	repeat (am)
		project_load_legacy_template()
	
	// Timelines
	am = buffer_read_int()
	debug("timelines", am)
	repeat (am)
		project_load_legacy_timeline()
	
	// Resources
	am = buffer_read_int()
	debug("resources", am)
	repeat (am)
		project_load_legacy_resource()
}
