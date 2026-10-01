function tab_timeline_editor_audio()
{
	tab_control_button_label()
	if (draw_button_label("timeline_editor/add_sound", floor(dx + dw/2), dy, null, icons.VOLUME, e_button.PRIMARY, null, e_anchor.CENTER))
	{
		bench_show_ani_type = "show"
		bench_open = true	
		bench_tab_select(e_bench_tab.SOUND)
	}
	tab_next()
}
