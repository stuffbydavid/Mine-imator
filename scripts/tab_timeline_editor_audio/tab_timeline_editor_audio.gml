/// tab_timeline_editor_audio()

function tab_timeline_editor_audio()
{
	tab_control_button_label()
	draw_button_label("timelineeditoraudioadd", floor(dx + dw/2), dy, null, null, e_button.PRIMARY, action_tl_add_sound, e_anchor.CENTER)
	tab_next()
}
