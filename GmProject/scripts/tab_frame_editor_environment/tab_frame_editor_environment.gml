function tab_frame_editor_environment()
{
	draw_tooltip_label(tl_edit.animated ? "frame_editor/environment/tip" : "frame_editor/environment/tip_non_animated", icons.INFO, e_toast.INFO)
	dy += 8

	tab_control_button_label()
	if (draw_button_label("frame_editor/environment/open", dx + dw / 2, dy, null, null, e_button.PRIMARY, null, e_anchor.CENTER))
	{
		tab_show(properties, true)
		properties.environment.show = true
	}
	tab_next()
}
