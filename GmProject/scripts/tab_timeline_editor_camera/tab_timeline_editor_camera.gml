function tab_timeline_editor_camera()
{
	tab_control_button_label()
	if (draw_button_label("timeline_editor/add_camera_effect", floor(dx + dw/2), dy, null, icons.WAND, e_button.PRIMARY, null, e_anchor.CENTER))
	{
		bench_show_ani_type = "show"
		bench_open = true	
		bench_tab_select(e_bench_tab.CAMERA_EFFECT)
	}
	tab_next()
}
