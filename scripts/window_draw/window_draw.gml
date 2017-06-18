/// window_draw()

if (exportmovie)
{
    window_draw_exportmovie()
    return 0
}

panel_area_draw()
window_draw_glow()
toolbar_draw()
window_draw_cover()
window_draw_timeline_move()
toolbar_draw_alerts()
if (!bench_show_ani)
    popup_draw()
menu_draw()
if (bench_show_ani)
    popup_draw()
tip_draw()
debug_info_draw()