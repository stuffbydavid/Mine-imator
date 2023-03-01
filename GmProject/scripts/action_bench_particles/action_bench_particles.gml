/// action_bench_particles(preset)
/// @arg preset

function action_bench_particles(fn)
{
	bench_settings.particle_preset = fn
	
	if (fn = "")
		return 0
	
	temp_creator = bench_settings
	bench_clear()
	particles_load(fn, bench_settings)
	temp_creator = app
	
	bench_settings.preview.fire = true
}
