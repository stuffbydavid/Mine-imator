/// @desc Exports a high-quality render pass for the current frame and render settings.

function tests_export_pass(directory, pass)
{
	var previouspass = project_render_pass;
	directory_create_lib(directory)
	project_render_pass = pass
	export_filename = directory + "/" + ds_list_find_value(render_pass_list, pass) + ".png"

	var starttime = get_timer();
	export_start("export_image")
	while (export_update()) {}

	log("Test render pass", export_filename, string_format((get_timer() - starttime) / 1000, 0, 3) + " msec")

	project_render_pass = previouspass
}
