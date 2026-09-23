/// tab_build_tool()

function tab_build_tool()
{
	if (!place_build)
	{
		tab_close(tab)
		return 0
	}

	// Options
	var optiony = dy
	if (build_first_person)
	{
		dy += 10
		draw_tooltip_label("buildtoolfirstpersontip", icons.INFO, e_toast.INFO)
	}
	else
	{
		var buttonwidth = floor((dw - 8) / 2)
		if (draw_button_label("buildtoolfirstperson", dx, dy, buttonwidth, null, e_button.PRIMARY))
			action_build_first_person(true)

		if (draw_button_label("buildtoolexit", dx + dw, dy, buttonwidth, null, e_button.PRIMARY, null, e_anchor.RIGHT))
		{
			app_stop_place()
			return 0
		}
	}
	
	dy = optiony + 40
	dh -= 40

	draw_label(text_get("buildtoolselected"), dx, dy + 12, fa_left, fa_middle, c_text_secondary, a_text_secondary, font_label)
	dy += 32
	dh -= 64

	// Re-use object editor with build_settings assigned
	var prevobj, listtop;
	prevobj = obj_edit
	listtop = dy
	obj_edit = build_settings
	tab_object_editor()
	
	// List and state widgets have the same bottom edge
	dy = listtop + dh + 8
	obj_edit = prevobj

	// Structure
	var structurevalue, structuretext, structurecapwidth;
	structurevalue = build_structure
	if (structurevalue != null && !instance_exists(structurevalue))
		structurevalue = null
	structuretext = text_get("buildtoolcreatenew")
	if (structurevalue != null)
		structuretext = structurevalue.display_name
	draw_set_font(font_label)
	structurecapwidth = string_width(text_get("buildtoolstructure")) + 8
	draw_button_menu("buildtoolstructure", e_menu.LIST, dx, dy, dw, 24, structurevalue, structuretext, action_build_structure_select, false, null, null, "", null, null, structurecapwidth)
}
