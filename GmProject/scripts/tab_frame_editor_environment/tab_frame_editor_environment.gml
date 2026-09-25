/// tab_frame_editor_environment()

function tab_frame_editor_environment()
{
	draw_tooltip_label("frameeditorenvironmenttip", icons.INFO, e_toast.INFO)
	dy += 8

	tab_control_button_label()
	if (draw_button_label("frameeditorenvironmentopen", dx + dw / 2, dy, null, null, e_button.PRIMARY, null, e_anchor.CENTER))
	{
		tab_show(properties, true)
		properties.background.show = true
	}
	tab_next()
}
