/// window_draw()

if (window_state = "load_assets")
{
	window_draw_load_assets()
	return 0
}

if (window_state = "new_assets")
{
	window_draw_new_assets()
	return 0
}

if (window_state = "export_movie")
{
	window_draw_exportmovie()
	return 0
}

if (window_state = "startup")
{
	window_draw_startup()
}
else
{
	panel_area_draw()
	window_draw_glow()
	toolbar_draw()
	window_draw_cover()
	window_draw_timeline_move()
	toolbar_draw_alerts()
}

if (!bench_show_ani)
	popup_draw()
menu_draw()
if (bench_show_ani)
	popup_draw()
tip_draw()
debug_info_draw()