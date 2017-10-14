/// action_bench_particles(preset)
/// @arg preset

var fn = argument0;
bench_settings.particle_preset = fn

if (fn = "")
	return 0

temp_creator = bench_settings
bench_clear()
particles_load(fn, bench_settings)
temp_creator = app

bench_settings.preview.fire = true
