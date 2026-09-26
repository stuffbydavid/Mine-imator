/// tab_timeline_editor_audio()

function tab_timeline_editor_audio()
{
	tab_control_button_label()
	if (draw_button_label("timelineeditoraddsound", floor(dx + dw/2), dy, null, icons.VOLUME, e_button.PRIMARY, null, e_anchor.CENTER))
	{
		bench_show_ani_type = "show"
		bench_open = true	
		bench_click(e_bench.SOUND)
	}
	tab_next()
}
