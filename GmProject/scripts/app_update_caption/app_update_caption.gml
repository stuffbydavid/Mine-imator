function app_update_caption()
{
	var cap = "Mine-imator";
	
	if (project_name != "")
		cap = project_name + string_repeat(" * ", project_changed) + " - " + cap
	
	window_set_caption(cap)
}
