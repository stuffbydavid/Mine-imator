/// action_bench_particles(preset)
/// @arg preset

function action_bench_particles(fn)
{
	if (fn = "")
		return 0
	
	var presetname = filename_new_ext(filename_name(fn), "");
	
	temp_creator = bench_settings
	bench_clear()
	particles_load(fn, bench_settings)
	temp_creator = app
	with (bench_settings)
	{
		name = text_exists("benchparticles" + presetname) ? text_get("benchparticles" + presetname) : presetname
		temp_update_display_name()
	}
	
	bench_settings.preview.fire = true
}
