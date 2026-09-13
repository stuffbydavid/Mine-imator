/// bench_show()

function bench_show()
{
	bench_show_ani_type = "show"
	window_busy = "bench"
	bench_settings_ani = 1
	bench_open = false
	
	if (bench_tab = e_bench.TEXT)
	{
		window_focus = string(bench_settings.tbx_text)
		preview_zoom_text(bench_settings.preview, bench_settings.text, bench_settings.text_font.font)
		bench_settings.preview.update = true
	}
	else if (bench_tab = e_bench.PARTICLE_SPAWNER)
		action_bench_particles_folder(bench_particle_preset_folder)
}
