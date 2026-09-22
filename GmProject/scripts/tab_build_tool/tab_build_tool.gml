/// tab_build_tool()

function tab_build_tool()
{
	if (!place_build)
	{
		tab_close(tab)
		return 0
	}

	// Options
	var buttonwidth = floor((dw - 8) / 2);
	if (draw_button_label("buildtoolfirstperson", dx, dy, buttonwidth, null, e_button.PRIMARY))
		toast_new(e_toast.INFO, "Coming soon")
	
	if (draw_button_label("buildtoolexit", dx + dw, dy, buttonwidth, null, e_button.PRIMARY, null, e_anchor.RIGHT))
	{
		app_stop_place()
		return 0
	}
	
	dy += 40
	dh -= 40

	draw_label(text_get("buildtoolselected"), dx, dy + 12, fa_left, fa_middle, c_text_secondary, a_text_secondary, font_label)
	dy += 32
	dh -= 32
	dh -= 4

	// Re-use object editor with build_settings assigned
	var prevobj, listtop;
	prevobj = obj_edit
	listtop = dy
	obj_edit = build_settings
	tab_object_editor()
	
	// List and state widgets have the same bottom edge
	dy = listtop + dh
	obj_edit = prevobj
}
