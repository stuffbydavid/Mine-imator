function bench_draw_settings_project()
{
	var list, selected;
	list = bench_settings.project_list
	selected = bench_settings.project_selected
	
	bench_create_disabled = (selected = null)
	bench_edit_hidden = false

	tab_control(bench_list_height(list))
	sortlist_draw(list, dx, dy, dw, tab_control_h, selected, true, text_get("type/project"))
	tab_next()
	
	window_scroll_focus = string(list.scroll)

	tab_control(ui_large_height)
	togglebutton_add("bench/project/library", null, bench_settings.project_lib_list, list = bench_settings.project_lib_list, action_bench_project_list)
	togglebutton_add("bench/project/resources", null, bench_settings.project_res_list, list = bench_settings.project_res_list, action_bench_project_list)
	togglebutton_add("bench/project/all", null, bench_settings.project_all_list, list = bench_settings.project_all_list, action_bench_project_list)
	draw_togglebutton("bench/project", dx, dy, true, false)
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
	if (draw_button_icon("bench/project/import", dx, dy, 24, 24, false, icons.ASSET_IMPORT, null, false, "tooltip/asset_import"))
		action_toolbar_import_asset()

	if (list = bench_settings.project_lib_list || list = bench_settings.project_all_list)
	{
		if (draw_button_icon("bench/project/duplicate", dx + 28, dy, 24, 24, false, icons.DUPLICATE, null, !temp, "tooltip/template/duplicate"))
		{
			action_lib_duplicate()
			action_bench_project_select(temp_edit)
		}

		if (list = bench_settings.project_lib_list)
		{
			if (draw_button_icon("bench/project/templateremove", dx + 56, dy, 24, 24, false, icons.DELETE, null, !temp, "tooltip/template/remove"))
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
				
		if (draw_button_icon("bench/project/save", dx + offset, dy, 24, 24, false, icons.ASSET_EXPORT, null, exportdisabled, "tooltip/resource/save"))
			action_res_export()

		if (draw_button_icon("bench/project/reload", dx + offset + 28, dy, 24, 24, false, icons.REFRESH, null, !res, "tooltip/resource/reload"))
			action_res_reload()

		if (draw_button_icon("bench/project/replace", dx + offset + 56, dy, 24, 24, false, icons.REPLACE, null, replacedisabled, "tooltip/resource/replace"))
			action_res_replace()

		if (list = bench_settings.project_res_list)
		{
			if (draw_button_icon("bench/project/resourceremove", dx + offset + 84, dy, 24, 24, false, icons.DELETE, null, !res, "tooltip/resource/remove"))
			{
				action_res_remove()
				selected = null
			}
		}
	}

	if (list = bench_settings.project_all_list)
	{
		if (draw_button_icon("bench/project/assetremove", dx + 140, dy, 24, 24, false, icons.DELETE, null, selected = null, "tooltip/asset_remove"))
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
