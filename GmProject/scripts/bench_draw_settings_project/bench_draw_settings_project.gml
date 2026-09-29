function bench_draw_settings_project()
{
	var list, selected;
	list = bench_settings.project_list
	selected = bench_settings.project_selected
	
	bench_create_disabled = (selected = null)
	bench_edit_hidden = false

	tab_control(bench_list_height(list))
	sortlist_draw(list, dx, dy, dw, tab_control_h, selected, true, text_get("typeproject"))
	tab_next()
	
	window_scroll_focus = string(list.scroll)

	tab_control(ui_large_height)
	togglebutton_add("benchprojectLibrary", null, bench_settings.project_lib_list, list = bench_settings.project_lib_list, action_bench_project_list)
	togglebutton_add("benchprojectResources", null, bench_settings.project_res_list, list = bench_settings.project_res_list, action_bench_project_list)
	togglebutton_add("benchprojectAll", null, bench_settings.project_all_list, list = bench_settings.project_all_list, action_bench_project_list)
	draw_togglebutton("benchproject", dx, dy, true, false)
	tab_next()

	var temp, res;
	temp = (selected != null && selected.object_index = obj_template)
	res = (selected != null && selected.object_index = obj_resource)
	if (temp)
		temp_edit = selected
	else if (res)
		res_edit = selected

	// Asset tools
	tab_control(24)
	if (draw_button_icon("benchprojectimport", dx, dy, 24, 24, false, icons.ASSET_IMPORT, null, false, "tooltipassetimport"))
		action_toolbar_import_asset()

	if (list = bench_settings.project_lib_list || list = bench_settings.project_all_list)
	{
		if (draw_button_icon("benchprojectduplicate", dx + 28, dy, 24, 24, false, icons.DUPLICATE, null, !temp, "tooltiptemplateduplicate"))
		{
			action_lib_duplicate()
			action_bench_project_select(temp_edit)
		}

		if (list = bench_settings.project_lib_list)
		{
			if (draw_button_icon("benchprojecttemplateremove", dx + 56, dy, 24, 24, false, icons.DELETE, null, !temp, "tooltiptemplateremove"))
			{
				action_lib_remove()
				selected = null
			}
		}
	}

	if (list = bench_settings.project_res_list || list = bench_settings.project_all_list)
	{
		var exportdisabled, replacedisabled, offset;
		exportdisabled = (!res || selected.type = e_res_type.FROM_WORLD)
		replacedisabled = (!res || selected.type = e_res_type.FROM_WORLD)
		offset = (list = bench_settings.project_all_list) ? 56 : 28
				
		if (draw_button_icon("benchprojectsave", dx + offset, dy, 24, 24, false, icons.ASSET_EXPORT, null, exportdisabled, "tooltipresourcesave"))
			action_res_export()

		if (draw_button_icon("benchprojectreload", dx + offset + 28, dy, 24, 24, false, icons.REFRESH, null, !res, "tooltipresourcereload"))
			action_res_reload()

		if (draw_button_icon("benchprojectreplace", dx + offset + 56, dy, 24, 24, false, icons.REPLACE, null, replacedisabled, "tooltipresourcereplace"))
			action_res_replace()

		if (list = bench_settings.project_res_list)
		{
			if (draw_button_icon("benchprojectresourceremove", dx + offset + 84, dy, 24, 24, false, icons.DELETE, null, !res, "tooltipresourceremove"))
			{
				action_res_remove()
				selected = null
			}
		}
	}

	if (list = bench_settings.project_all_list)
	{
		if (draw_button_icon("benchprojectassetremove", dx + 140, dy, 24, 24, false, icons.DELETE, null, selected = null, "tooltipassetremove"))
		{
			if (temp)
				action_lib_remove()
			else if (res)
				action_res_remove()
			selected = null
		}
	}
			
	tab_next()

	// res editor
	if (selected != null && selected.object_index = obj_resource)
	{
		preview_edit = bench_settings.preview
		tab_properties_resources_edit()
	}

	// Hide edit/create options for resources
	if (list = bench_settings.project_res_list)
		bench_buttons_hidden = true
	else if (list = bench_settings.project_all_list)
		bench_buttons_hidden = (selected != null && selected.object_index = obj_resource)
}
