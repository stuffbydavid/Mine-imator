/// bench_show()

function bench_show()
{
	action_tl_play_break()
	bench_show_ani_type = "show"
	window_busy = "bench"
	bench_settings_ani = 1
	bench_open = false
	
	// Select audio track
	if (bench_tab = e_bench.SOUND)
		bench_audio_track_update()
	
	// Load particle folder
	else if (bench_tab = e_bench.PARTICLE_SPAWNER)
		action_bench_particles_folder(bench_particle_preset_folder)
	
	// Highlight text and adjust zoom
	else if (bench_tab = e_bench.TEXT)
	{
		window_focus = string(bench_settings.tbx_text)
		preview_zoom_text(bench_settings.preview, bench_settings.text, bench_settings.text_font.font)
	}
}
