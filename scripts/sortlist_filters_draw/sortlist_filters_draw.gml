/// sortlist_filters_draw()

var typelist = null;

// Filter "type" collumn
if (settings_menu_sortlist = app.properties.library.list)
	typelist = temp_type_name_list

if (typelist = null)
	return 0

dx = content_x + 8
dy = content_y + 8

scissor_start(content_x, content_y, settings_menu_w, settings_menu_h)

var scroll = 0;

if (settings_menu_scroll.needed)
	scroll = -settings_menu_scroll.value

for (var i = 0; i < ds_list_size(typelist); i++)
{
	var active = ds_list_find_index(settings_menu_sortlist.filter_list, typelist[|i]) != -1;
	
	tab_control_checkbox()
	if (draw_checkbox("type" + typelist[|i], dx, dy + scroll, active, null))
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

if ((dy - content_y) > 256)
{
	scrollbar_draw(settings_menu_scroll, e_scroll.VERTICAL, content_x + content_width - 10, content_y, content_height, dy - content_y)
	window_scroll_focus = string(settings_menu_scroll)
}