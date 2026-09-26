/// sortlist_filters_draw()

function sortlist_filters_draw()
{
	var typelist, textprefix, scroll, capwid;
	typelist = null
	textprefix = "type"
	scroll = 0
	capwid = 0
	
	// Filter "type" column
	typelist = settings_menu_sortlist.filter_type_list

	if (typelist = null)
		return 0
	
	clip_begin(content_x, content_y, settings_menu_w, settings_menu_h)
	
	if (settings_menu_scroll.needed)
		scroll = -settings_menu_scroll.value
	else
		scroll = 0
	settings_menu_sortlist.filter_scroll = settings_menu_scroll.value
	
	draw_set_font(font_label)
	
	for (var i = 0; i < ds_list_size(typelist); i++)
	{
		var itemname = typelist[|i];
		
		// Skip internal resource types
		if (typelist = res_type_name_list)
		{
			if (itemname = "packunzipped" || itemname = "legacyblocksheet")
				continue
		}
		
		capwid = max(capwid, string_width(text_get(textprefix + itemname)))
		
		var active = ds_list_find_index(settings_menu_sortlist.filter_list, itemname) != -1
		
		tab_control_checkbox()
		if (draw_checkbox(textprefix + itemname, dx, dy + floor(scroll), active, null))
		{
			if (active)
				ds_list_delete_value(settings_menu_sortlist.filter_list, itemname)
			else
				ds_list_add(settings_menu_sortlist.filter_list, itemname)
		
			sortlist_update(settings_menu_sortlist)
		}
		tab_next()
	}
	
	clip_end()
	
	settings_menu_w = (32 + capwid) + 32 + 24
}
