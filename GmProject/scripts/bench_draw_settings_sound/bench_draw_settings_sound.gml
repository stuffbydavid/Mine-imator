function bench_draw_settings_sound()
{
	tab_control(bench_list_height(bench_settings.sound_list_current))
	soundlist_draw(bench_settings.sound_list_current, dx, dy, dw, tab_control_h, text_get("bench" + (bench_settings.sound_list_current.source = "music" ? "music" : "sound")))
	tab_next()
	dy -= 4

	if (minecraft_game_found)
	{
		tab_control_togglebutton()
		togglebutton_add("benchsoundsounds", null, "sounds", bench_settings.sound_list_current.source = "sounds", action_bench_sound_source)
		togglebutton_add("benchsoundmusic", null, "music", bench_settings.sound_list_current.source = "music", action_bench_sound_source)
		togglebutton_add("benchsoundproject", null, "project", bench_settings.sound_list_current.source = "project", action_bench_sound_source)
		draw_togglebutton("benchsound", dx, dy, true, false)
		
		dy += ui_large_height + 6
	}

	tab_control(24)

	// Import sound
	if (draw_button_icon("benchsoundimport", dx, dy, 24, 24, false, icons.ASSET_ADD, null, false, "tooltipsoundimport"))
		action_bench_sound_import()

	// Export sound
	if (draw_button_icon("benchsoundexport", dx + 28, dy, 24, 24, false, icons.ASSET_EXPORT, null, bench_settings.sound_list_current.selected = null, "tooltipsoundexport"))
		action_bench_sound_export()

	tab_next()

	// Missing Minecraft
	if (!minecraft_game_found)
		draw_tooltip_label("benchsoundtip", icons.INFO, e_toast.INFO)

	// Audio track
	dy += 8
	if (bench_settings.audio_track != null && (!instance_exists(bench_settings.audio_track) || bench_settings.audio_track.type != e_tl_type.AUDIO_TRACK))
		bench_settings.audio_track = null

	tab_control_menu()
	draw_button_menu("benchaudiotrack", e_menu.LIST, dx, dy, dw, 24, bench_settings.audio_track, bench_settings.audio_track != null ? bench_settings.audio_track.display_name : text_get("benchaudiotracknew"), action_bench_audio_track)
	tab_next()

	dy += ui_small_height

	window_scroll_focus = string(bench_settings.sound_list_current.scroll)
	bench_create_disabled = !is_array(bench_settings.sound_list_current.select)
}
