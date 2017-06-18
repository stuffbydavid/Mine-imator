/// bench_clear()
/// @desc Clear templates and resources associated with the workbench.

with (obj_template)
	if (creator = app.bench_settings)
		instance_destroy()

with (obj_resource)
	if (creator = app.bench_settings)
		instance_destroy()