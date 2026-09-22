/// bench_show()

function bench_show()
{
	if (place_build)
		app_stop_place(false, false)

	action_tl_play_break()
	
	window_busy = "bench"
	bench_show_ani_type = "show"
	bench_open = false
	
	bench_settings_ani = 1
	bench_settings.preview.update = true
	if (bench_settings.list_focus != "")
		window_focus = bench_settings.list_focus
	
	// Select audio track
	if (bench_tab = e_bench.SOUND)
		bench_audio_track_update()
	
	// Refresh schematic project folder
	else if (bench_tab = e_bench.SCHEMATIC && bench_schematic_folder = "project")
		action_bench_schematic_folder(bench_schematic_folder)

	// Load particle folder
	else if (bench_tab = e_bench.PARTICLE_SPAWNER)
		action_bench_particles_folder(bench_particle_preset_folder)
	
	// Adjust zoom and highlight text on tab click
	else if (bench_tab = e_bench.TEXT)
	{
		preview_zoom_text(bench_settings.preview, bench_settings.text, res_eval(bench_settings.text_font).font)
		if (!keybinds[e_keybind.WORKBENCH].pressed)
			window_focus = string(bench_settings.tbx_text)
	}
}
