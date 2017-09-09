/// project_load_legacy_objects()

// Templates
repeat (buffer_read_int())
	project_load_legacy_template()

// Timelines
repeat (buffer_read_int())
	project_load_legacy_timeline()

// Resources
var am = buffer_read_int()
repeat (am)
	project_load_legacy_resource()
