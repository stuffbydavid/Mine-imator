function bench_draw_settings_world()
{
	bench_buttons_hidden = true

	draw_tooltip_label("benchworldtip1", icons.INFO, e_toast.INFO)
	dy += 8
	draw_tooltip_label("benchworldtip2", null, e_toast.INFO)
	dy += ui_large_height

	// Import from world
	tab_control(64)
	if (draw_button_label("benchimportfromworld", dx + dw / 2, dy, 200, icons.SCENERY, e_button.MEDIUM, null, e_anchor.CENTER))
		world_import_begin(false)
	tab_next()
}
