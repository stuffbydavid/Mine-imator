/// tab_get_title(tab)
/// @arg tab
/// @desc Returns the tab title.

var tab = argument0;

if (tab = properties)
	return text_get("tabprojectproperties")
else if (tab = timeline)
	return text_get("tabtimeline")
else if (tab = template_editor)
{
	if (!temp_edit)
		return ""
	switch (temp_edit.type)
	{
		case "char":
			return text_get("tabcharmodel", string_remove_newline(temp_edit.display_name))
		
		case "spblock":
		case "block":
			return text_get("tabblock", string_remove_newline(temp_edit.display_name))
		
		case "item":
			return text_get("tabitem", string_remove_newline(temp_edit.display_name))
		
		case "bodypart":
			return text_get("tabbodypart", string_remove_newline(temp_edit.display_name))
		
		case "particles":
			return text_get("tabparticles", string_remove_newline(temp_edit.display_name))
	}
}
else if (tab = ground_editor)
	return text_get("tabground")
else if (tab = timeline_editor)
{
	var name = "";
	if (tl_edit)
	{
		name = string_remove_newline(tl_edit.display_name)
		if (tl_edit_amount > 1)
			name += "..."
	}
	return text_get("tabtimelineeditor", name)
}
else if (tab = frame_editor)
{
	var name = "";
	if (tl_edit)
	{
		name = string_remove_newline(tl_edit.display_name)
		if (tl_edit_amount > 1)
			name += "..."
	}
	return text_get("tabframeeditor", string(round(timeline_marker)), name)
}
else if (tab = settings)
	return text_get("tabsettings")

return ""
