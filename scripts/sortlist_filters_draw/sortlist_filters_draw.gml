/// sortlist_filters_draw()

var typelist, scroll, itemname;
typelist = null
scroll = 0

// Filter "type" collumn
if (settings_menu_sortlist = app.properties.library.list)
	typelist = temp_type_name_list

if (settings_menu_sortlist = app.properties.resources.list)
	typelist = res_type_name_list

if (typelist = null)
	return 0

dx = content_x + 8
dy = content_y + 8

scissor_start(content_x, content_y, settings_menu_w, settings_menu_h)

if (settings_menu_scroll.needed)
	scroll = -settings_menu_scroll.value
else
	scroll = 0

for (var i = 0; i < ds_list_size(typelist); i++)
{
	itemname = typelist[|i]
	
	// Skip items (Resources sortlist)
	if (typelist = res_type_name_list)
	{
		if (itemname = "packunzipped" || itemname = "legacyblocksheet" || itemname = "fromworld")
			continue
	}
	
	var active = ds_list_find_index(settings_menu_sortlist.filter_list, typelist[|i]) != -1;
	
	tab_control_checkbox()
	if (draw_checkbox("type" + itemname, dx, dy + scroll, active, null))
	{
		if (active)
			ds_list_delete_value(settings_menu_sortlist.filter_list, typelist[|i])
		else
			ds_list_add(settings_menu_sortlist.filter_list, typelist[|i])
		
		sortlist_update(settings_menu_sortlist)
	}
	tab_next()
}

scissor_done()

settings_menu_w = 186
settings_menu_h = min(dy - content_y, 256)

if ((settings_menu_y + settings_menu_h) > window_height)
	settings_menu_y -= (settings_menu_button_h + settings_menu_h)

if ((dy - content_y) > 256)
{
	scrollbar_draw(settings_menu_scroll, e_scroll.VERTICAL, content_x + content_width - 12, content_y, content_height, dy - content_y)
	window_scroll_focus = string(settings_menu_scroll)
}