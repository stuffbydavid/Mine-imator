/// tab_properties_resources()

function tab_properties_resources()
{
	var capwid;
	
	// Preview selected resource
	tab_control(160)
	preview_draw(res_preview, dx, dy, dw, 160)
	tab_next()
	
	// List
	tab_control_sortlist(tab.resources.list)
	sortlist_draw(tab.resources.list, dx, dy, dw, tab_control_h, res_edit)
	tab_next()
	
	// Tools
	tab_control(24)
	
	if (draw_button_icon("resourcesnew", dx, dy, 24, 24, false, icons.ASSET_IMPORT, null, false, "tooltipresourcenew"))
		action_toolbar_import_asset()
	
	if (draw_button_icon("previewexport", dx + 28, dy, 24, 24, false, icons.ASSET_EXPORT, null, (!res_edit || res_edit.type = e_res_type.FROM_WORLD), "tooltipresourcesave"))
		action_res_export()
	
	if (draw_button_icon("resourcesreload", dx + (28 * 2), dy, 24, 24, false, icons.REFRESH, null, (!res_edit || res_edit = mc_res), "tooltipresourcereload"))
		action_res_reload()
	
	if (draw_button_icon("resourcesreplace", dx + (28 * 3), dy, 24, 24, false, icons.REPLACE, null, (!res_edit || res_edit = mc_res || res_edit.type = e_res_type.FROM_WORLD), "tooltipresourcereplace"))
		action_res_replace()
	
	if (draw_button_icon("resourcesremove", dx + (28 * 4), dy, 24, 24, false, icons.DELETE, null, (!res_edit || res_edit = mc_res), "tooltipresourceremove"))
		action_res_remove()
	
	tab_next()
	
	if (res_edit != null)
	{
		preview_edit = res_preview
		tab_properties_resources_edit()
	}
}
