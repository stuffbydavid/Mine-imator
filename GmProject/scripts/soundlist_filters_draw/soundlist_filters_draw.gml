/// soundlist_filters_draw()

function soundlist_filters_draw()
{
	var slist, list, prefix, scroll, capwid, filter, active;
	slist = settings_menu_soundlist
	if (slist.source = "music")
	{
		list = minecraft_music_filter_list
		prefix = "musicfilter"
	}
	else
	{
		list = minecraft_sound_filter_list
		prefix = "soundfilter"
	}
	scroll = settings_menu_scroll.needed ? -settings_menu_scroll.value : 0
	capwid = 0

	clip_begin(content_x, content_y, settings_menu_w, settings_menu_h)
	draw_set_font(font_label)
	for (var i = 0; i < ds_list_size(list); i++)
	{
		filter = list[|i]
		capwid = max(capwid, string_width(text_get(prefix + filter)))
		active = ds_list_find_index(slist.filter_list, i) >= 0

		tab_control_checkbox()
		if (draw_checkbox(prefix + filter, dx, dy + floor(scroll), active, null))
		{
			if (active)
				ds_list_delete_value(slist.filter_list, i)
			else
				ds_list_add(slist.filter_list, i)
			soundlist_update(slist)
		}
		tab_next()
	}
	clip_end()
	settings_menu_w = 88 + capwid
}
