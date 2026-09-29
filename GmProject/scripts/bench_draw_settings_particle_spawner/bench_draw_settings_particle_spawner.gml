function bench_draw_settings_particle_spawner()
{
	bench_edit_hidden = !setting_advanced_mode
	bench_edit_name = "benchcreateedit"
	bench_edit_button = e_bench_button.CREATE_AND_EDIT

	// Particles
	tab_control(bench_list_height(bench_settings.particle_preset_list))
	sortlist_draw(bench_settings.particle_preset_list, dx, dy, dw, tab_control_h, bench_settings.particle_preset, false, text_get("benchparticlepreset"))
	tab_next()
	dy -= 4

	// Particles folder
	tab_control_togglebutton()
	for (var i = 0; i < array_length(particle_folders); i++)
	{
		var particlefolder = particle_folders[i];
		togglebutton_add("benchparticles" + string_replace_all(string_lower(particlefolder), " ", "_"), null, particlefolder, bench_particle_preset_folder = particlefolder, action_bench_particles_folder)
	}
	togglebutton_add("benchparticlesproject", null, "project", bench_particle_preset_folder = "project", action_bench_particles_folder)
	draw_togglebutton("benchparticlepreset", dx, dy, true, false)
	dy += ui_large_height + 6

	tab_control(24)

	// Import particles
	if (draw_button_icon("benchparticlesimport", dx, dy, 24, 24, false, icons.ASSET_ADD, null, false, "tooltipparticlesimport"))
		action_bench_particles_import()

	// Export particles
	if (draw_button_icon("benchparticlesexport", dx + 28, dy, 24, 24, false, icons.ASSET_EXPORT, null, bench_settings.particle_preset = null, "tooltipparticlesexport"))
		action_bench_particles_export()

	// Open folder
	if (draw_button_icon("benchparticlesopenfolder", dx + 56, dy, 24, 24, false, icons.FOLDER, null, false, "tooltipparticlesopenfolder"))
		action_bench_particles_open_folder()

	// Reload folder
	if (draw_button_icon("benchparticlesreload", dx + 84, dy, 24, 24, false, icons.REFRESH, null, false, "tooltipparticlesreloadfolder"))
		action_bench_particles_folder(bench_particle_preset_folder)

	tab_next()

	bench_create_disabled = bench_settings.particle_preset = null
	window_scroll_focus = string(bench_settings.particle_preset_list.scroll)
}
